pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

/**
    Implementing the basic Logic of "Scalable Reward Distribution with Changing Take Sizes" as described in https://solmaz.io/2019/02/24/scalable-reward-changing/
 */
abstract contract RewardBasedPool {

    uint public totalStake;
    uint public rewardPerToken;
    mapping(address => uint) public stake;
    mapping(address => uint) public rewardTally; //Tracks the cumulative rewards NOT distributed to the address, because he didn´t stake yet

    function depositStake(uint amount) public {

        doDeposit(amount);

        stake[msg.sender] = stake[msg.sender] + amount;
        rewardTally[msg.sender] = rewardTally[msg.sender] + rewardPerToken * amount / 1 ether;
        totalStake = totalStake + amount;

    }

    function beforeDeposit(uint amount) internal virtual { }

    /* Function to be overriden if necessary. Transfers the deposit tokens at deposit */
    function doDeposit(uint amount) internal virtual { }

    function distribute(uint _reward) virtual public {
        require(totalStake > 0, "At least one staker has to be in the pool");

        rewardPerToken = rewardPerToken + _reward * 1 ether / totalStake;

    }

    function doDistribute(uint _reward) internal virtual {
    }

    function reward(address addr) public view returns (uint) {

        return stake[addr] * rewardPerToken / 1 ether - rewardTally[addr];

    }

    function withdrawStake(uint amount) public {

        require(stake[msg.sender] >= amount, "Cannot withdraw more than staked amount");

        stake[msg.sender] = stake[msg.sender] - amount;
        rewardTally[msg.sender] = rewardTally[msg.sender] - rewardPerToken * amount / 1 ether;
        totalStake = totalStake - amount;
        doWithdrawStake(amount);

    }

    function doWithdrawStake(uint amount) internal virtual {
    }

    function withdrawReward() public {

        uint calculatedReward = reward(msg.sender);
        rewardTally[msg.sender] = stake[msg.sender] * rewardPerToken / 1 ether;
        doWithdrawReward(calculatedReward);
    }

    function doWithdrawReward(uint calculatedReward) internal virtual { }

    function withdrawAll() public {
        withdrawReward();
        withdrawStake(stake[msg.sender]);
    }

}