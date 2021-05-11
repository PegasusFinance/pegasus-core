const Distributor = artifacts.require("RewardDistributor");
const WETH = artifacts.require("WETH");
const { ethers } = require("ethers");

contract('Controller', function(accounts) {

    it("DistributorTest", async () => {

        let weth = await WETH.deployed();
        let d = await Distributor.new(accounts[2], {from: accounts[1]});

        await d.setDirect(accounts[3])

        await weth.deposit({value: ethers.utils.parseEther("2")})
        await weth.transfer(d.address, ethers.utils.parseEther("1"));
        await d.feePaid(weth.address, ethers.utils.parseEther("1"));

        assert.equal((await weth.balanceOf(accounts[3])).toString(), ethers.utils.parseEther("0.5").toString(), "Rewards not recieved");

        await d.withdrawDev([weth.address], {from: accounts[2]});
        assert.equal((await weth.balanceOf(accounts[2])).toString(), ethers.utils.parseEther("0.5").toString(), "Rewards not recieved");

    })
})