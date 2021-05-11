const Distributor = artifacts.require("RewardDistributor");
const WETH = artifacts.require("WETH");
const Controller = artifacts.require("Controller");
const IBunnyVault = artifacts.require("IBunnyVault");
const BunnyStrategy = artifacts.require("BunnySingleLiquidityStrategy")

const constants = require("../migrations/config.js");
const { ethers } = require("ethers");
const BigNumber = ethers.BigNumber;

contract('Controller', function(accounts, network) {

    it("Integration 1", async () => {

        let weth;

        if(process.env.NETWORK === "mainnetfork"){

            weth = await WETH.at(constants.weth);

            let bal = await weth.balanceOf(accounts[0])
            
            if(!BigNumber.from(bal.toString()).gt(BigNumber.from("0"))){
                await weth.transfer(accounts[0], ethers.utils.parseEther("5"), {from: constants.main_account});
            }
            console.log((await weth.balanceOf(accounts[0])).toString());

        }else{
            weth = await WETH.deployed();
        }

        // let bunnyPool = await IBunnyVault.at("0xCADc8CB26c8C7cB46500E61171b5F27e9bd7889D")
        // console.log((await bunnyPool.balanceOf("0xd46f7E32050f9B9A2416c9BB4E5b4296b890A911")).toString());
        




    })
})

