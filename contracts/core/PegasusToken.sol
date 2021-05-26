pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../utils/Whitelist.sol";

contract PegasusToken is ERC20, Whitelist{

    constructor() ERC20("Pegasus Token", "PEGASUS"){

    }

    function canMint(address addr) public view returns (bool){
        return isMember(addr);
    }

    function mintFor(address adr, uint amount) public {
        require(isMember(msg.sender), "Caller is not authorized");
        _mint(adr, amount);
    }

}