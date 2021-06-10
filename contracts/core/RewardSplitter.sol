pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IController.sol";
import "../interfaces/IFeePayable.sol";
import "../interfaces/IPool.sol";
import "../interfaces/IUniswapRouter.sol";
import "../interfaces/IRewardReciever.sol";
import "../interfaces/IPegasusTokenMinter.sol";

contract RewardSplitter is Ownable, IFeePayable{

    using SafeMath for uint256;

    IController controller;
    // IFeePayable distributor;
    IUniswapV2Router01 router;
    IRewardReciever rewardReciever;
    IERC20 wbnb;
    IPegasusTokenMinter minter;

    // uint256 wbnbDecimals; //TODO Is this more efficient than calling wbnb.decimals() every time?

    constructor(address _controller, address _router, address _rewardReciever, address _wbnb, address pegToken){
        controller = IController(_controller);
        router = IUniswapV2Router01(_router);
        wbnb = IERC20(_wbnb);
        // wbnbDecimals = wbnb.decimals();
        minter = IPegasusTokenMinter(pegToken);
        
        _setRewardReciever(_rewardReciever);
    }

    function _setRewardReciever(address _rewardReciever) public onlyOwner {
        rewardReciever = IRewardReciever(_rewardReciever);
        wbnb.approve(_rewardReciever, ~uint(0));
    }

    // mapping()
    modifier onlyPool() {
        require(controller.buybackSplit(msg.sender) > 0, "Caller is not a pool");
        _;
    }

    function feePaid(address pool, uint256 amountToken) public override /*onlyStrategy */ {

        require(controller.isPool(pool), "Pool not registered in Controller");
        address token = IPool(pool).token();
        swapAllToBnb(token);//, /*amountToken*/);

        uint256 amount = wbnb.balanceOf(address(this));
        
        uint256 split = controller.buybackSplit(pool);
        uint256 rewardDistributed = amount.mul(split).div(1000000);
        
        address distributor = controller.feeCollector();
        wbnb.transfer(distributor, amount - rewardDistributed);
        // distributor.feePaid(IPool(pool).token(), amount - rewardDistributed);

        //Distribute into PEG-Pool
        rewardReciever.distribute(rewardDistributed);

        //Mint PEG for Fee-paying Pool
        uint256 mint = rewardDistributed.mul(controller.PEGperBNB()).div(1e18); //1e18 = 1 wbnb
        minter.mintFor(pool, mint);

    }

    function swapAllToBnb(address token) internal {

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = address(wbnb);

        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).approve(address(router), balance);
        router.swapExactTokensForTokens(balance, 0, path, address(this), block.timestamp);

    }

    // function feePaid(address pool, uint256 shares) public override onlyPool {

    //     uint256 split = controller.buybackSplit(pool);
    //     uint256 buyback = split.mul(split).div(1000000);

    //     address token = IPool(pool).token();

    //     swapToBnb(token, buyback);

    //     IERC20(token).transfer(address(distributor), shares - buyback);
    //     distributor.feePaid(IPool(pool).token(), shares - buyback);
    // }

    // function buyBack(address token, uint256 shares) public return(uint) {

    //     address[] memory path = new address[](2);
    //     path[0] = token;
    //     path[1] = 



    // }

}