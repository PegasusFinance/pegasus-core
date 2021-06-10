pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Test is ERC20{

    // IPoolRewards rewards = IPoolRewards(0x93567318aaBd27E21c52F766d2844Fc6De9Dc738);

    constructor(uint256 initialBalance) ERC20("Test", "TST") {
        _mint(msg.sender, initialBalance);
    }

    function getY() public view returns (uint){
        return 123525;
    }

    // function getClaimable(address a) public view returns (uint) {
    //     return rewards.claimable(a);
    // }

}