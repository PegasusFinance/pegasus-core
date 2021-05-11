pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface IFeePayable {

    function feePaid(address tokenAdr, uint amount) external;

}