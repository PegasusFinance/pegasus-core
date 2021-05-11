pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "./RewardBasedPool.sol";
import "../interfaces/IUniswapRouter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PegasusPool is RewardBasedPool {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    IUniswapV2Router02 router;
    IERC20 wbnb;

    /**
    In this case, _token should be Pegasus Token, _rewardToken is PEG-BNB-Flip
     */
    constructor(address _token, address _rewardToken, address _wbnb, address _router) RewardBasedPool(_token, _rewardToken){
        wbnb = IERC20(_wbnb);
        router = IUniswapV2Router02(_router);

        wbnb.approve(address(router), 2**256-1);
        IERC20(_rewardToken).approve(address(router), 2**256-1);
    }

    function distribute(uint _rewardBnb) override public {

        wbnb.safeTransferFrom(msg.sender, address(this), _rewardBnb);
        //_rewardBnb = wbnb.balanceOf(this);

        uint sellAmount = _rewardBnb.div(2);

        address[] memory path = new address[](2);
        path[0] = address(wbnb);
        path[1] = address(rewardToken);

        uint swappedAmount = router.swapExactTokensForTokens(sellAmount, 0, path, address(this), block.timestamp)[path.length - 1];

        (,, uint lp) = router.addLiquidity(path[0], path[1], _rewardBnb.sub(sellAmount), swappedAmount, 0, 0, address(this), block.timestamp);

        super.distribute(lp);

    }

    function withdrawReward() override public {

        uint calculatedReward = reward(msg.sender);
        rewardTally[msg.sender] = stake[msg.sender] * rewardPerToken / 1 ether;

        router.removeLiquidity(address(wbnb), address(rewardToken), calculatedReward, 0, 0, msg.sender, block.timestamp);

    }

}