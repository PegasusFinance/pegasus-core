const Migrations = artifacts.require("Migrations");
const WETH = artifacts.require("WETH");
const data = require("./config.js");
const { ethers } = require("ethers");

module.exports = async function(deployer, network, accounts) {
  process.env.NETWORK = deployer.network;
  if(data.ignorednets.includes(network)) return;
  
  await deployer.deploy(Migrations);

  let weth;
  if(data.devnets.includes(network)){

    await deployer.deploy(WETH, {overwrite: false});
    weth = await WETH.deployed();
    console.log("WETH Address: " + weth.address);

  }
  // else if(network === "mainnetfork"){

  //   weth = await WETH.at(data.weth);

  // }

  // if(network === "mainnetfork"){
  //   console.log(accounts[0]);
  //   await weth.transfer(accounts[0], ethers.utils.parseEther("3"), {from: data.main_account});
  //   console.log((await weth.balanceOf(accounts[0])).toString());
  // }
};
