pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface IPegasusTokenMinter {

    function canMint(address addr) external view returns (bool);

    function mintFor(address adr, uint amount) external ;

}