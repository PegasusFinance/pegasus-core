const Controller = artifacts.require("Controller");

const SafeMath = artifacts.require("SafeMath")
const SafeERC20 = artifacts.require("SafeERC20")

const ETHPool = artifacts.require("ETHPool")
const SampleStrategy = artifacts.require("SampleStrategy")

const WETH = artifacts.require("WETH");

module.exports = async function(deployer, network) {

    let controller = await Controller.deployed();
    let pool = await ETHPool.deployed();
    let weth = await WETH.deployed();
    console.log("ETHPool: " + pool.address);

    deployer.link(SafeMath, SampleStrategy);
    deployer.link(SafeERC20, SampleStrategy);

    await deployer.deploy(SampleStrategy, controller.address, pool.address, weth.address);
    let strategy = await SampleStrategy.deployed();
    console.log("Strategy: " + strategy.address);
    console.log("Controller: " + controller.address);

    let p = await strategy.pool()
    console.log("Strat Pool: " + p);

    await controller.updateStrategy(pool.address, strategy.address);

};
