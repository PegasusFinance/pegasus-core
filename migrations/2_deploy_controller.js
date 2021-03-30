const Controller = artifacts.require("Controller");
const SafeMath = artifacts.require("SafeMath");
const SafeERC20 = artifacts.require("SafeERC20");

module.exports = function(deployer, network) {
    if(network == "testing") return;

    deployer.deploy(Controller);

    deployer.deploy(SafeMath);
    deployer.deploy(SafeERC20);

};
