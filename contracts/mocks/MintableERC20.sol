pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintableERC20 is ERC20 {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {

    }

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
    
    function mint(address adr, uint256 amount) public {
        _mint(adr, amount);
    }

}