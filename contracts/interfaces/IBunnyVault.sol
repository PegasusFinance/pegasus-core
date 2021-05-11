pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

interface IBunnyVault {

    function deposit(uint256 _amount) external;
    function depositAll() external;
    function withdraw(uint256 _amount) external;    // BUNNY STAKING POOL ONLY
    function withdrawAll() external;
    function getReward() external;                  // BUNNY STAKING POOL ONLY
    function harvest() external;

    function totalSupply() external view returns (uint256);
    function balance() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function sharesOf(address account) external view returns (uint256);
    function principalOf(address account) external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function withdrawableBalanceOf(address account) external view returns (uint256);   // BUNNY STAKING POOL ONLY
    function priceShare() external view returns (uint256);

    function withdrawUnderlying(uint256 _amount) external;

}