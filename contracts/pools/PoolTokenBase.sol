pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IPool.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IController.sol";

abstract contract PoolTokenBase is ERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public immutable token;
    IController public immutable controller;

    uint256 constant MAX_UINT_VALUE = ~uint256(0);

    event Deposit(address indexed user, uint256 shares, uint256 amount);
    event Withdraw(address indexed user, uint256 shares, uint256 amount);

    constructor(address _token, address _controller)
        ERC20("Pegasus ETH Pool", "vpETH")
    {
        token = IERC20(_token);
        controller = IController(_controller);
    }
    
    modifier onlyController() {
        require(address(controller) == msg.sender, "Caller is not the controller");
        _;
    }

    /// @dev Approve strategy to spend collateral token and strategy token of pool.
    function approveToken() external virtual onlyController {
        address strategy = controller.strategy(address(this));
        token.safeApprove(strategy, MAX_UINT_VALUE);
        // IERC20(IStrategy(strategy).token()).safeApprove(strategy, MAX_UINT_VALUE); //Since Strategies are not tokenized yet, we dont need that
    }

    /// @dev Reset token approval of strategy. Called when updating strategy.
    function resetApproval() external virtual onlyController {
        address strategy = controller.strategy(address(this));
        token.safeApprove(strategy, 0);
        // IERC20(IStrategy(strategy).token()).safeApprove(strategy, 0); //Same as in approveToken()
    }

    function deposit(uint256) external virtual;

    function withdraw(uint256) external virtual;

    function rebalance() external virtual {
        IStrategy strategy = IStrategy(controller.strategy(address(this)));
        strategy.rebalance();
    }


    // function sweepErc20(address) external;

    //function withdrawByStrategy(uint256) external;

    // function feeCollector() public view returns (address){

    //     controller.feeCollector();

    // }

    function getPricePerShare() public view virtual returns (uint256){
        if (totalSupply() == 0) {
            return convertFrom18(1e18);
        }
        return totalValue().mul(1e18).div(totalSupply());
    }

    /// @dev Returns collateral token locked in strategy
    function tokenLocked() public view virtual returns (uint256) {
        IStrategy strategy = IStrategy(controller.strategy(address(this)));
        return strategy.totalLocked();
    }

    /// @dev Returns the amount of tokens currently on the Pool Contract
    function tokensHere() public view virtual returns (uint256) {
        return token.balanceOf(address(this));
    }

    /// @dev Returns total value of vesper pool, in terms of collateral token
    function totalValue() public view returns (uint256) {
        return tokenLocked().add(tokensHere());
    }

    function withdrawFee() public view returns (uint256) {
        return controller.withdrawFee(address(this));
    }

    /// @dev Convert to 18 decimals from token defined decimals. Default no conversion.
    function convertTo18(uint256 amount) public pure virtual returns (uint256) {
        return amount;
    }

    /// @dev Convert from 18 decimals to token defined decimals. Default no conversion.
    function convertFrom18(uint256 amount) public pure virtual returns (uint256) {
        return amount;
    }

    function _calculateShares(uint256 amount) internal view virtual returns (uint256) {
        // require(amount != 0, "amount is 0");

        uint256 _totalSupply = totalSupply();
        uint256 _totalValue = convertTo18(totalValue());
        uint256 shares =
            (_totalSupply == 0 || _totalValue == 0)
                ? amount
                : amount.mul(_totalSupply).div(_totalValue);
        return shares;

    }

    ///@dev Handles fee and returns the amount left for withdrawal
    function _handleFee(uint256 shares) internal returns (uint256 _sharesAfterFee){

        uint256 shareFee = withdrawFee();
        if (shareFee != 0) {
            uint256 _fee = shares.mul(shareFee).div(1e18);
            _sharesAfterFee = shares.sub(_fee);
            _transfer(_msgSender(), controller.feeCollector(), _fee);
            //Something like: controller.feeCollector().feePaid(address(this), _fee)
        } else {
            _sharesAfterFee = shares;
        }

    }

}