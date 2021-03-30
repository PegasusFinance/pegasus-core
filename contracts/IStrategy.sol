pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface IStrategy {

    function rebalance() external;

    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function withdrawAll() external;

    //function isUpgradable() external view returns (bool);

    //function isReservedToken(address _token) external view returns (bool);

    //function token() external view returns (address);

    function pool() external view returns (address);

    function totalLocked() external view returns (uint256);

    //Lifecycle functions
    function pause() external;

    function unpause() external;
}