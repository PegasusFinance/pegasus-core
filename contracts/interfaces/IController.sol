pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface IController {

    function withdrawFee(address) external view returns (uint256);
    function interestFee(address) external view returns (uint256);
    function buybackSplit(address) external view returns (uint256);
    function PEGperBNB() external view returns (uint256);
    function strategy(address) external view returns (address);
    function feeCollector() external view returns (address);
    function uniswapRouter() external view returns (address);
    // function pools(uint) external view returns (address);
    function isPool(address) external view returns (bool);

}