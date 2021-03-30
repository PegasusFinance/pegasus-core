pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool is IERC20 {
    function approveToken() external;

    function deposit(uint256) external;

    function withdraw(uint256) external;

    function rebalance() external;

    function resetApproval() external;

    // function sweepErc20(address) external;

    //function withdrawByStrategy(uint256) external;

    // function feeCollector() external view returns (address);

    function getPricePerShare() external view returns (uint256);

    function token() external view returns (address);

    function tokensHere() external view returns (uint256);

    function totalValue() external view returns (uint256);

    function withdrawFee() external view returns (uint256);
}

interface IEtherPool is IPool {

    function deposit() external payable;

    function withdrawETH(uint256) external;
    
}