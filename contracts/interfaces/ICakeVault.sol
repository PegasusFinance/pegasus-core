pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface ICakeVault {
    function priceShare() external view returns(uint);
    function balanceOf(address account) external view returns(uint);
    function sharesOf(address account) external view returns(uint);
    function deposit(uint _amount) external;
    function withdraw(uint256 _amount) external;
}