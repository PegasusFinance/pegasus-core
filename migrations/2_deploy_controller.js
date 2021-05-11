const Controller = artifacts.require("Controller");
const SafeMath = artifacts.require("SafeMath");
const SafeERC20 = artifacts.require("SafeERC20");

const data = require("./config.js");

module.exports = function(deployer, network) {
    if(data.ignorednets.includes(network)) return;

    deployer.deploy(Controller);

    deployer.deploy(SafeMath);
    deployer.deploy(SafeERC20);

};
