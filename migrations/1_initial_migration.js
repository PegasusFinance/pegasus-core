const Migrations = artifacts.require("Migrations");
const WETH = artifacts.require("WETH");

module.exports = async function(deployer, network) {
  if(network == "testing") return;
  
  await deployer.deploy(Migrations);

  await deployer.deploy(WETH, {overwrite: false});
  let weth = await WETH.deployed();
  console.log("WETH Address: " + weth.address);
};
