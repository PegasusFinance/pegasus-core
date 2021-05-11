const Controller = artifacts.require("Controller");

const SafeMath = artifacts.require("SafeMath")
const SafeERC20 = artifacts.require("SafeERC20")

const ETHPool = artifacts.require("ETHPool")
const WETH = artifacts.require("WETH");

const data = require("./config.js")

module.exports = async function(deployer, network) {
    if(data.ignorednets.includes(network)) return;

    let controller = await Controller.deployed();
    let weth_address = "";
    
    if(data.devnets.includes(network)){
        weth_address = (await WETH.deployed()).address;
    }else if(network === "mainnetfork"){
        weth_address = data.weth;
    }

    console.log("Controller: " + controller.address);

    deployer.link(SafeMath, ETHPool);
    deployer.link(SafeERC20, ETHPool);

    await deployer.deploy(ETHPool, controller.address, weth_address);
    let pool = await ETHPool.deployed();

    await controller.addPool(pool.address);

};
