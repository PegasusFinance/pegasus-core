pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IUniswapRouter.sol";
import "./StrategyBase.sol";

interface IVSPPool is IERC20{
    function deposit() external payable;

    function deposit(uint256) external;

    function sweepErc20(address) external;

    function withdraw(uint256) external;

    function withdrawETH(uint256) external;

    function withdrawByStrategy(uint256) external;

    function getPricePerShare() external view returns (uint256);

    function token() external view returns (address);

    function tokensHere() external view returns (uint256);

    function totalValue() external view returns (uint256);

    function withdrawFee() external view returns (uint256);

    function convertFrom18(uint256) external pure returns (uint256);
}

interface IPoolRewards {
    function notifyRewardAmount(uint256) external;

    function claimReward(address) external;

    function updateReward(address) external;

    function rewardForDuration() external view returns (uint256);

    function claimable(address) external view returns (uint256);

    function pool() external view returns (address);

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);
}

contract VesperStrategy is StrategyBase {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public token;

    IVSPPool vspPool;

    IPoolRewards poolRewards = IPoolRewards(0x93567318aaBd27E21c52F766d2844Fc6De9Dc738);
    address vspToken = 0x1b40183EFB4Dd766f11bDa7A7c3AD8982e998421;

    uint32 lastVSPClaim; //TODO If no smaller Datatypes come, change to uint256

    constructor(address _controller, address _pool, address _token, address _vspPool) StrategyBase(_controller, _pool) {

        token = IERC20(_token);
        vspPool = IVSPPool(_vspPool);

        IERC20(vspToken).approve(controller.uniswapRouter(), 2**256-1);
        //TODO Debug
        require(IERC20(vspToken).allowance(controller.uniswapRouter(), address(this)) == 2**256-1, "failed");

        lastVSPClaim = uint32(block.timestamp);
    }

    function rebalance() public override {

        uint256 currentBalance = token.balanceOf(address(this));
        uint256 locked = lockedInVSP();
        uint256 p1 = locked.div(100);
        if(currentBalance > p1.mul(2)){ //Greater than 2% -> Reduce to 1%

            uint256 depositAmount = currentBalance - p1;
            vspPool.deposit(depositAmount);

        }
        // else if(currentBalance < 1p){}


    }

    // event Log(uint256 index, uint256 a);
    // event Log4(uint256 index, address a);

    function deposit(uint256 amount) public override onlyPool {

        // emit Log(1, amount);
        // emit Log4(2, msg.sender);
        // emit Log4(3, address(pool));
        // emit Log4(4, address(this));
        token.transferFrom(pool, address(this), amount);

    }

    function withdraw(uint256 amount) public override onlyPool {

        //TODO Check if there is enough WETH, if not withdraw collateral
        token.transfer(pool, amount);

    }

    function withdrawAll() public override onlyController {
        claimVspAndSwap(claimableVSP());
        vspPool.withdraw(vspPool.balanceOf(address(this)));
        // withdrawFromVSP(totalLocked());
        token.safeTransfer(pool, token.balanceOf(address(this)));
    }

    function claimableVSP() public view returns (uint256){
        return poolRewards.claimable(address(this));
    }

    /// @dev Withdraws specified ETH amount from vETH Pool, either using VSP Rewards or withdrawing Collateral
    function withdrawFromVSP(uint256 amount) internal {

        // uint vspclaimable = claimableVSP();
        // uint vspcollateral = vspCollateral();

        // if(vspclaimable >= amount.mul(controller.interestFee(address(pool))) { //TODO Has to be multiplied by price
        //     if(block.timestamp > lastVSPClaim + 12 hours){
        //         claimVspAndSwap(vspclaimable);
        //     }
        // }

        uint256 shares = amount.mul(vspPool.convertFrom18(1e18)).div(vspPool.getPricePerShare());
        //TODO Make sure, it isn´t too less because of rounding errors
        vspPool.withdraw(shares);

    }

    function claimVspAndSwap(uint256 vspclaimable) internal {
        poolRewards.claimReward(address(this));
        uint256 swapped = swapVSP(vspclaimable);
        uint256 fee = swapped.mul(15).div(100);
        token.transfer(controller.feeCollector(), fee);

    }

    function swapVSP(uint256 amount) internal returns (uint256) {

        uint256 deadline = block.timestamp + 15;
        address[] memory path = new address[](2);  //TODO Maybe als Storage Array vorinitialisieren?
        path[0] = vspToken;
        path[1] = address(token);
        IUniswapV2Router02 router = IUniswapV2Router02(controller.uniswapRouter());
        uint256 swapped = router.swapExactTokensForTokens(amount, 1 /*TODO*/, path, address(this), deadline)[path.length - 1];
        return swapped;

    }

    function vspPrice() internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = vspToken;
        path[1] = address(token);
        uint256 price = IUniswapV2Router02(controller.uniswapRouter()).getAmountsOut(1e18, path)[0];
        return price;
    }

    //function isUpgradable() external view returns (bool);

    //function isReservedToken(address _token) external view returns (bool);

    //function token() external view returns (address);

    function vspCollateral() internal view returns (uint256) {
        return vspPool.balanceOf(address(this)).mul(vspPool.getPricePerShare()).div(1e18);
    }

    function lockedInVSP() public view returns (uint256) {

        return vspCollateral().add(claimableVSP());

    }

    function totalLocked() public override view returns (uint256) {

        //TODO ADD VSP Logic

        return token.balanceOf(address(this))
                .add(lockedInVSP());

    }

    //DEBUG ------------

    function deposit() public payable {

    }

}