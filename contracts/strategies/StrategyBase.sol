pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "../interfaces/IController.sol";
import "../interfaces/IStrategy.sol";

abstract contract StrategyBase is IStrategy {
    
    address public override pool; 
    IController public controller;

    constructor(address _controller, address _pool) {
        controller = IController(_controller);
        require(controller.isPool(_pool), "Not a valid Pool");
        pool = _pool;
    }

    modifier onlyController() {
        require(msg.sender == address(controller), "Caller is not the controller");
        _;
    }

    modifier onlyPool() {
        require(msg.sender == address(pool), "Caller is not pool");
        _;
    }

}