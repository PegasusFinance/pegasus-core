const Controller = artifacts.require("Controller");

const SafeMath = artifacts.require("SafeMath")
const SafeERC20 = artifacts.require("SafeERC20")

const ETHPool = artifacts.require("ETHPool")
const SampleStrategy = artifacts.require("SampleStrategy")
const BunnyStrategy = artifacts.require("BunnySingleLiquidityStrategy")

const WETH = artifacts.require("WETH");
const config = require("./config.js");

module.exports = async function(deployer, network) {
    if(config.ignorednets.includes(network)) return;

    let weth_address = "";
    if(config.devnets.includes(network)){
        let weth = await WETH.deployed();
        weth_address = weth.address;
    }else if(network == "mainnetfork"){
        weth_address = config.weth;
    }

    let controller = await Controller.deployed();
    let pool = await ETHPool.deployed();

    console.log("ETHPool: " + pool.address);

    deployer.link(SafeMath, BunnyStrategy)
    deployer.link(SafeERC20, BunnyStrategy)

    console.log("Linked");

    await deployer.deploy(BunnyStrategy, controller.address, pool.address, config.weth_pool, config.router);
    console.log("Deployed")
    let strategy = await BunnyStrategy.deployed();

    // deployer.link(SafeMath, SampleStrategy);
    // deployer.link(SafeERC20, SampleStrategy);

    // await deployer.deploy(SampleStrategy, controller.address, pool.address, weth_address);
    // let strategy = await SampleStrategy.deployed();
    console.log("Strategy: " + strategy.address);
    console.log("Controller: " + controller.address);

    let p = await strategy.pool()
    console.log("Strat Pool: " + p);

    await controller.updateStrategy(pool.address, strategy.address);

};
