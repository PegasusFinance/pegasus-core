pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./StrategyBase.sol";
import "../interfaces/IUniswapRouter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IBunnyVault.sol";
import "../interfaces/IBunnyMinterV2.sol";
import "../interfaces/IBunnyPriceCalculator.sol";
import "../interfaces/IPool.sol";

abstract contract SingleLiquidityTokenStrategy is StrategyBase {
    
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 token;

    uint256 totalLPs;

    constructor(address _controller, address _pool) StrategyBase(_controller, _pool){
        token = IERC20(IPool(_pool).token());
    }

    function deposit(uint256 amount) override public {
        
        token.safeTransferFrom(msg.sender, address(this), amount);
        totalLPs = totalLPs.add(depositLiquidity(amount));
        
    }

    function withdraw(uint256 amount) public override onlyPool{ //Returns weather the withdraw has been successful

        uint256 withdrawn = 0;

        uint256 balance = token.balanceOf(address(this));
        if(balance < amount){

            if(outstandingRewards() >= amount){ //Enough?

                withdrawn = withdrawn.add(withdrawRewards());

                if(balance.add(withdrawn) < amount){
                    uint256 withdrawAmount = amount - (withdrawn + balance); //Already secured by previous if
                    withdrawn = withdrawn.add(withdrawLiquidity(withdrawAmount));
                }

            }else{
                withdrawn = withdrawn.add(withdrawLiquidity(amount - balance));
            }

        }
    
        // uint256 finalBalance = token.balanceOf(address(this));
        // require(finalBalance >= amount); //That shouldn´t really happen though, right?

        token.safeTransfer(address(pool), withdrawn);

    }

    function withdrawAll() public override onlyController {
        withdrawRewards();
        withdraw(totalLPs);
        token.safeTransfer(address(pool), token.balanceOf(address(this)));
    }

    function depositLiquidity(uint amount) virtual public returns (uint256); //Returns amount of LPs
    function withdrawLiquidity(uint lps) virtual public returns (uint256);
    function withdrawRewards() virtual public returns (uint256);
    function outstandingRewards() virtual public returns (uint256);  //Returns e
    function outstandingRewardsFeeSubtracted() virtual public returns (uint256);  

}

abstract contract BunnySingleLiquidityStrategy is SingleLiquidityTokenStrategy {

    using SafeMath for uint256;

    IBunnyVault public bunnypool;
    IUniswapV2Router01 public router;
    IERC20 public bunny = IERC20(0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51);

    uint256 rewardRatio = 0.7 ether;
    uint256 minusVenusFee = 9997;

    uint256 withdrawalFeePeriod = 3 days;
    uint256 bunnyWithdrawalFee = 50; //pp 10k

    uint256 lastDeposit;


        bunnypool = IBunnyVault(_bunnypool);
        router = IUniswapV2Router01(_router);

    }

    function totalLocked() public override view returns (uint256){
        return token.balanceOf(address(this))
          + bunnypool.principalOf(address(this)).mul(minusVenusFee).div(10000) //0,03% Venus Fee
          + outstandingRewards();
    }
 
    function depositLiquidity(uint256 amount) override public returns (uint256){ //Returns amount of LPs

        rebalance();
        return amount;

    }

    function withdrawLiquidity(uint256 lps) override public returns (uint256){

        uint256 before = token.balanceOf(address(this));
        uint256 withdrawAmount = lps.mul(10000 + (10000 - minusVenusFee)).div(10000);

        if(lastDeposit + withdrawalFeePeriod > block.timestamp){
            withdrawAmount = withdrawAmount.mul(10000 + 50).div(10000);
        }

        bunnypool.withdrawUnderlying(withdrawAmount);
        //Tasdasdasd
        return token.balanceOf(address(this)) - before;

    }

    function withdrawRewards() override public returns (uint256){
        
        uint256 before = token.balanceOf(address(this));
        bunnypool.getReward();
        swapBunny();
        return token.balanceOf(address(this)) - before;

    }

    function swapBunny() public returns (uint256){

        address[] memory path = new address[](2);
        path[0] = address(bunny);
        path[1] = address(token);
        uint256 received = router.swapExactTokensForTokens(bunny.balanceOf(address(this)), 0, path, address(this), block.timestamp)[1];  //TODO Make safe and not arbitrageable

        require(received >= token.balanceOf(address(this))); //TODO Maybe remove or make with before & after

        return received; //TODO Remove received

    }

    function outstandingRewards() override public view returns (uint256){
        uint256 earned = bunnypool.earned(address(this));
        uint256 nominalTokenRewards = earned.mul(rewardRatio).div(1 ether);

        //The next part is probably very expensive for the actual effect. Probably just using earned is sufficient
        IBunnyMinterV2 bunnyMinter = IBunnyMinterV2(bunnypool.minter());
        IPriceCalculator calculator = IPriceCalculator(bunnyMinter.priceCalculator());
        (uint256 bnb,) = calculator.valueOfAsset(address(token), (earned - nominalTokenRewards));
        uint256 outstandingBunny = bunnyMinter.amountBunnyToMint(bnb);
        // address[] memory arr = new address[](2);
        // arr[0] = address(bunny);
        // arr[1] = address(token);
        // uint256[] memory prices = calculator.pricesInUSD(arr);
        uint256 bunnyRewardsConverted = 0;//prices[0].mul(1 ether).mul(outstandingBunny).div(prices[1]);

        return (nominalTokenRewards.add(bunnyRewardsConverted));
    }

    function outstandingRewardsFeeSubtracted() override public view returns (uint256){

        uint256 interestFee = controller.interestFee(pool);
        return outstandingRewards().mul(1000000 - interestFee).div(1000000);

    }


    uint256 capitalCache = 20; //pp 10k

    function rebalance() override public{
        
        uint256 nextWindow = lastDeposit + withdrawalFeePeriod + 1 days;
        if(nextWindow < block.timestamp){
            uint256 amount = token.balanceOf(address(this)).mul(10000 - capitalCache).div(10000);
            bunnypool.deposit(amount);
            lastDeposit = nextWindow;
        }

    }

}