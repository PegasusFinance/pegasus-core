pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IPool.sol";

contract Controller is Ownable {

    mapping(address => uint256) public withdrawFee;
    mapping(address => uint256) public interestFee; //ppm
    mapping(address => uint256) public buybackSplit; //ppm
    address public feeCollector = 0x11923d873e2030d45aCe9cfc63B12257205Ee609;

    mapping(address => address) public strategy;
    
    address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address[] public pools;

    uint constant MAX_VALUE = ~uint(0);

    function updateWithdrawFee(address _pool, uint256 _fee) external onlyOwner {
        require(_fee <= 1e18, "More than 100%");
        require(feeCollector != address(0), "Feecollector not set");
        withdrawFee[_pool] = _fee;
    }

    function updateInterestFee(address _pool, uint256 _fee) external onlyOwner {
        require(_fee <= 1e18, "More than 100%");
        require(feeCollector != address(0), "Feecollector not set");
        interestFee[_pool] = _fee;
    }

    function updateBuybackSplit(address _pool, uint256 _split) external onlyOwner {
        require(feeCollector != address(0), "Feecollector not set");
        buybackSplit[_pool] = _split;
    }

    function updateUniswapRouter(address _uniswapRouter) external onlyOwner {
        require(_uniswapRouter != address(0), "Uniswap-Router cant be zero-address");
        uniswapRouter = _uniswapRouter;
    }

    function updateFeeCollector(address _feeCollector) external onlyOwner {
        require(_feeCollector != address(0), "FeeCollector cant be zero-address");
        feeCollector = _feeCollector;
    }

    /**
     * @dev Add new pool in system
     * @param _pool Address of new pool
     */
    function addPool(address _pool) external onlyOwner {
        require(_pool != address(0), "invalid-pool");
        IERC20 pool = IERC20(_pool);
        require(pool.totalSupply() == 0, "Zero supply required");
        pools.push(_pool);
        withdrawFee[_pool] =  6e15; //Default: 0,6%
        interestFee[_pool] = 15e16; //Default: 15%
    }

    /**
     * @dev Remove pool from system
     * @param _pool Address of pool to be removed
     */
    function removePool(address _pool) external onlyOwner {

        IERC20 pool = IERC20(_pool);
        require(pool.totalSupply() == 0, "Zero supply required");

        uint i = indexOfPool(_pool);
        require(i == MAX_VALUE, "Pool doesnt exist");

        if(i == pools.length - 1){
            pools.pop();
        }else{
            pools[i] = pools[pools.length - 1]; //TODO Check if pop() actually returns the value //pools[pools.length - 1];
            pools.pop();
        }
    }

    function indexOfPool(address _pool) internal view returns (uint) {
        for(uint i = 0 ; i < pools.length ; i++){
            if(pools[i] == _pool){
                return i;
            }
        }
        return MAX_VALUE;
    }

    function isPool(address _pool) public view returns (bool) {
        return indexOfPool(_pool) < MAX_VALUE;
    }

    modifier validPool(address _pool) {
        require(indexOfPool(_pool) < MAX_VALUE, "Not a valid pool");
        _;
    }

    event Log(uint256 indexed i, address addr);
    event LogB(uint256 indexed i, bool m);

    function updateStrategy(address _pool, address _newStrategy)
        external
        onlyOwner
        validPool(_pool)
    {
        require(_newStrategy != address(0), "invalid strategy address");
        address currentStrategy = strategy[_pool];
        
        require(IStrategy(_newStrategy).pool() == _pool, "wrong-pool");
        IPool vpool = IPool(_pool);
        if (currentStrategy != address(0)) {
        //     require(IStrategy(currentStrategy).isUpgradable(), "strategy-is-not-upgradable");
            vpool.resetApproval();
        }
        strategy[_pool] = _newStrategy;
        vpool.approveToken(); 
    }

}