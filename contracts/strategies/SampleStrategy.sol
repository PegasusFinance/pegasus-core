pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "../interfaces/IPool.sol";
import "../interfaces/IController.sol";
import "../interfaces/IWETH.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SampleStrategy {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IPool public pool; //TODO IPool necessary?
    IController public controller;

    IWETH weth;

    constructor(address _controller, address _pool, address _weth){
        weth = IWETH(_weth);
        controller = IController(_controller);
        require(controller.isPool(_pool), "Not a valid Pool");
        pool = IPool(_pool);
    }

    modifier onlyController() {
        require(msg.sender == address(controller), "Caller is not the controller");
        _;
    }

    modifier onlyPool() {
        require(msg.sender == address(pool), "Caller is not pool");
        _;
    }

    function rebalance() external {

    }

    // event Log(uint256 index, uint256 a);
    // event Log4(uint256 index, address a);

    function deposit(uint256 amount) public {

        // emit Log(1, amount);
        // emit Log4(2, msg.sender);
        // emit Log4(3, address(pool));
        // emit Log4(4, address(this));
        weth.transferFrom(address(pool), address(this), amount);

    }

    function withdraw(uint256 amount) public onlyPool {

        //TODO Check if there is enough WETH, if not withdraw collateral
        weth.transfer(address(pool), amount);

    }

    function withdrawAll() public onlyController {
        withdrawFromVSP(totalLocked());
        IERC20(address(weth)).safeTransfer(address(pool), weth.balanceOf(address(this)));
    }

    function withdrawFromVSP(uint256 amount) internal {



    }

    //function isUpgradable() external view returns (bool);

    //function isReservedToken(address _token) external view returns (bool);

    //function token() external view returns (address);

    function lockedInVSP() public view returns (uint256) {



    }

    function totalLocked() public view returns (uint256) {

        //TODO ADD VSP Logic

        return weth.balanceOf(address(this));

    }

    //DEBUG ------------

    function deposit() public payable {

    }

}