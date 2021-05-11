pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./StrategyBase.sol";
import "../interfaces/IUniswapRouter.sol";
import "../interfaces/IPool.sol";

abstract contract LiquidityBasedStrategy is StrategyBase {
    
    IERC20 token1;
    IERC20 token2;
    IERC20 lp;
    address depositToken;
    IUniswapV2Router01 router;

    constructor(address _token1, address _token2, address _lp, address _router){
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        lp = IERC20(_lp);
        depositToken = IPool(pool).token();
        router = IUniswapV2Router01(_router);
    }

    function deposit(uint256 amount) override public {
        
        
        
    }

    // function withdraw(uint256 amount) external virtual;

    function withdrawAll() override public{// onlyController {

    }

    function rebalance() override public {

    }

    // function pool() external virtual view returns (address);

    // function totalLocked() external virtual view returns (uint256);

    function depositLiquidity(uint AmountToken1, uint AmountToken2) virtual public returns (uint); //Returns amount of LPs
    function withdrawLiquidity(uint lps) virtual public returns (uint, uint);
    function withdrawRewards() virtual public returns (uint, uint);

}