pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "./RewardBasedTokenPool.sol";
import "../interfaces/IUniswapRouter.sol";
import "../interfaces/IRewardReciever.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PegasusPool is RewardBasedTokenPool, IRewardReciever {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    IUniswapV2Router02 router;
    IERC20 wbnb;

    /**
    In this case, _token should be Pegasus Token, _rewardToken is PEG-BNB-Flip
     */
    constructor(address _token, address _rewardToken, address _wbnb, address _router) RewardBasedTokenPool(_token, _rewardToken){
        wbnb = IERC20(_wbnb);
        router = IUniswapV2Router02(_router);

        wbnb.approve(address(router), ~uint(0));
        IERC20(_rewardToken).approve(address(router), ~uint(0));
    }

    function distribute(uint _rewardBnb) override(RewardBasedPool, IRewardReciever) public {

        wbnb.safeTransferFrom(msg.sender, address(this), _rewardBnb);
        //_rewardBnb = wbnb.balanceOf(this);

        uint sellAmount = _rewardBnb.div(2);

        address[] memory path = new address[](2);
        path[0] = address(wbnb);
        path[1] = address(rewardToken);

        uint swappedAmount = router.swapExactTokensForTokens(sellAmount, 0, path, address(this), block.timestamp)[path.length - 1];

        (,, uint lp) = router.addLiquidity(path[0], path[1], _rewardBnb.sub(sellAmount), swappedAmount, 0, 0, address(this), block.timestamp);

        RewardBasedPool.distribute(lp);

    }

    function doDistribute(uint _shares) override internal { }

    function doWithdrawReward(uint calculatedReward) override internal {
        router.removeLiquidity(address(wbnb), address(rewardToken), calculatedReward, 0, 0, msg.sender, block.timestamp);
    }

    // function withdrawReward() override public {

    //     uint achievedReward = reward(msg.sender);
    //     rewardTally[msg.sender] = stake[msg.sender] * rewardPerToken / 1 ether;

    //     router.removeLiquidity(address(wbnb), address(rewardToken), achievedReward, 0, 0, msg.sender, block.timestamp);

    // }

}