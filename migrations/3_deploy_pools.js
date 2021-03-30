const Controller = artifacts.require("Controller");

const SafeMath = artifacts.require("SafeMath")
const SafeERC20 = artifacts.require("SafeERC20")

const ETHPool = artifacts.require("ETHPool")
const WETH = artifacts.require("WETH");

module.exports = async function(deployer, network) {
    if(network == "testing") return;

    let controller = await Controller.deployed();
    let weth = await WETH.deployed();
    console.log("Controller: " + controller.address);

    deployer.link(SafeMath, ETHPool);
    deployer.link(SafeERC20, ETHPool);

    await deployer.deploy(ETHPool, controller.address, weth.address);
    let pool = await ETHPool.deployed();

    await controller.addPool(pool.address);

};
