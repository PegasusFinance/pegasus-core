/**

 _____                                 ______ _                            
|  __ \                               |  ____(_)                           
| |__) |__  __ _  __ _ ___ _   _ ___  | |__   _ _ __   __ _ _ __   ___ ___ 
|  ___/ _ \/ _` |/ _` / __| | | / __| |  __| | | '_ \ / _` | '_ \ / __/ _ \
| |  |  __/ (_| | (_| \__ \ |_| \__ \ | |    | | | | | (_| | | | | (_|  __/
|_|   \___|\__, |\__,_|___/\__,_|___/ |_|    |_|_| |_|\__,_|_| |_|\___\___|
            __/ |                                                          
           |___/                                                           


 */

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "./PoolTokenBase.sol";
import "./RewardBasedPool.sol";
import "../interfaces/IWETH.sol";

contract ETHPool is PoolTokenBase, RewardBasedPool {
    //TODO Check if maybe reimplementing it would be better, since a lot of it is unused
    
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IWETH weth;

    bool canDeposit = true;

    constructor(address _controller, address _weth, address _rewardToken)
        PoolTokenBase(_weth, _controller)
    {
        weth = IWETH(_weth);
    }

    function deposit(uint256 amount) external override {
        uint256 shares = _calculateShares(convertTo18(amount));
    
        token.safeTransferFrom(msg.sender, address(this), amount);

        depositStrategy(amount);
        _mint(msg.sender, shares);

        _depositStake(shares);
        emit Deposit(msg.sender, shares, amount);
    }

    function deposit() public payable {
        uint256 shares = _calculateShares(convertTo18(msg.value));

        weth.deposit{value: msg.value}();
        //TODO Check if WETH are minted for msg.sender or pool

        depositStrategy(msg.value);
        _mint(msg.sender, shares);

        _depositStake(shares);
        emit Deposit(msg.sender, shares, msg.value);
    }

    function depositStrategy(uint256 _amount) internal {

        address strat = controller.strategy(address(this));
        weth.approve(strat, _amount);
        IStrategy(strat).deposit(_amount);

    }

    function withdrawETH(uint256 shares) external {
        _withdraw(shares, true);
    }

    function withdraw(uint256 shares) external override {
        _withdraw(shares, false);
    }

    function _withdraw(uint256 shares, bool eth) internal {
        
        // _beforeBurning(shares);
        uint256 sharesAfterFee = _handleFee(shares);
        uint256 amount =
            convertFrom18(sharesAfterFee.mul(convertTo18(totalValue())).div(totalSupply()));

        _withdrawStake(shares);
        
        _burn(msg.sender, sharesAfterFee);
        transferWithdraw(amount, eth);
        emit Withdraw(msg.sender, shares, amount);
    }

    function transferWithdraw(uint256 _amount, bool _eth) internal {
        
        uint256 balanceHere = tokensHere();
        if (balanceHere < _amount) {
            _withdrawCollateral(_amount.sub(balanceHere));
            balanceHere = tokensHere();
            _amount = balanceHere < _amount ? balanceHere : _amount;
        }
        if(!_eth){
            token.safeTransfer(msg.sender, _amount);
        }else{
            canDeposit = false;
            weth.withdraw(_amount);
            canDeposit = true;

            payable(msg.sender).transfer(_amount);
        }

    }

    function _withdrawCollateral(uint256 amount) internal {

        IStrategy strat = IStrategy(controller.strategy(address(this)));
        strat.withdraw(amount);

    }

    receive() external payable {
        if(canDeposit){
            deposit();
        }
    }

    /**
    -------  Pegasus Token Reward Overrides --------
    */

    function doDeposit(uint amount) override internal {

        //Do nothing, since this is implicitly called when depositing
    }



}