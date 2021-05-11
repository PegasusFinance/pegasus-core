pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RewardBasedPool {

    using SafeERC20 for IERC20;

    IERC20 token;
    IERC20 rewardToken;

    uint public totalStake;
    uint public rewardPerToken;
    mapping(address => uint) public stake;
    mapping(address => uint) public rewardTally;

    constructor(address _token, address _rewardToken) {
        token = IERC20(_token);
        rewardToken = IERC20(_rewardToken);
    }

    function depositStake(uint amount) public {

        token.safeTransferFrom(msg.sender, address(this), amount);

        stake[msg.sender] = stake[msg.sender] + amount;
        rewardTally[msg.sender] = rewardTally[msg.sender] + rewardPerToken * amount / 1 ether;
        totalStake = totalStake + amount;

    }

    function distribute(uint _reward) public virtual {
        require(totalStake > 0, "At least one staker has to be in the pool");

        rewardToken.safeTransferFrom(msg.sender, address(this), _reward);
        rewardPerToken = rewardPerToken + _reward * 1 ether / totalStake;

    }

    function reward(address addr) public view returns (uint) {

        return stake[addr] * rewardPerToken / 1 ether - rewardTally[addr];

    }

    function withdrawStake(uint amount) public {

        require(stake[msg.sender] >= amount, "Cannot withdraw more than staked amount");

        stake[msg.sender] = stake[msg.sender] - amount;
        rewardTally[msg.sender] = rewardTally[msg.sender] - rewardPerToken * amount / 1 ether;
        totalStake = totalStake - amount;
        token.transfer(msg.sender, amount);

    }

    function withdrawReward() public virtual {

        uint calculatedReward = reward(msg.sender);
        rewardTally[msg.sender] = stake[msg.sender] * rewardPerToken / 1 ether;
        rewardToken.transfer(msg.sender, calculatedReward);

    }

    function withdrawAll() public {
        withdrawReward();
        withdrawStake(stake[msg.sender]);
    }

}