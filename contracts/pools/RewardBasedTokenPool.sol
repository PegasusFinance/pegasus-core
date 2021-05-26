pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RewardBasedPool.sol";

/**
Implementation of RewardBasedPool with two ERC20 Tokens as Deposit and Reward
*/
contract RewardBasedTokenPool is RewardBasedPool{

    using SafeERC20 for IERC20;

    IERC20 stakingToken;
    IERC20 rewardToken;

    constructor(address _token, address _rewardToken) {
        stakingToken = IERC20(_token);
        rewardToken = IERC20(_rewardToken);
    }
    
    function doDeposit(uint amount) internal override virtual {
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function doWithdrawStake(uint amount) internal override virtual {
        stakingToken.transfer(msg.sender, amount);
    }
    
    function doWithdrawReward(uint calculatedReward) internal override virtual {
        rewardToken.transfer(msg.sender, calculatedReward);
    }

    function doDistribute(uint _reward) internal override virtual {
        rewardToken.safeTransferFrom(msg.sender, address(this), _reward);
    }

}