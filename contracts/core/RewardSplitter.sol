pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IController.sol";
import "../interfaces/IFeePayable.sol";
import "../interfaces/IPool.sol";

contract RewardSplitter is Ownable{

    using SafeMath for uint256;

    IController controller;
    IFeePayable distributor;

    constructor(address _controller){
        controller = IController(_controller);
    }

    // mapping()
    modifier onlyPool() {
        require(controller.buybackSplit(msg.sender) > 0, "Caller is not a pool");
        _;
    }

    function feePaid(address pool, uint256 shares) public onlyPool {

        uint256 split = controller.buybackSplit(pool);
        uint256 buyback = split.mul(split).div(1000000);

        buyBack(buyback);

        IERC20(pool).transfer(address(distributor), shares - buyback);
        distributor.feePaid(IPool(pool).token(), shares - buyback);
    }

    function buyBack(uint256 shares) public {





    }

}