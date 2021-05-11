const Pool = artifacts.require("RewardBasedPool");
const WETH = artifacts.require("WETH");
const SampleStrategy = artifacts.require("SampleStrategy");
const { ethers } = require("ethers");

contract('Controller', function(accounts) {

    it("Deploy", async () => {

        let weth = await WETH.deployed();
        let weth2 = await WETH.new();
        let pool = await Pool.new(weth.address, weth2.address);

        const ether = ethers.utils.parseEther("1");

        await weth.deposit({value: ether});
        await weth.approve(pool.address, ethers.utils.parseEther("10000"));
        await weth2.approve(pool.address, ethers.utils.parseEther("10000"));
        await pool.depositStake(ether);

        assert.equal((await pool.stake(accounts[0])).toString(), ethers.utils.parseEther('1').toString(), "Deposit not recieved correctly");

        await weth2.deposit({value: ether.div(2)});
        await pool.distribute(ether.div(2));
        
        assert.equal((await pool.reward(accounts[0])).toString(), ethers.utils.parseEther('0.5').toString(), "Reward not calculated correctly");

        await weth.deposit({value: ether.mul(2), from: accounts[1]});
        await weth.approve(pool.address, ethers.utils.parseEther("10000"), {from: accounts[1]});
        await pool.depositStake(ether.mul(2), {from: accounts[1]});

        await weth2.deposit({value: ether.mul(3).div(2)});
        await pool.distribute(ether.mul(3).div(2));

        assert.equal((await pool.reward(accounts[0])).toString(), ether.toString(), "Reward not calculated correctly 2");
        assert.equal((await pool.reward(accounts[1])).toString(), ethers.utils.parseEther('1'), "Reward not calculated correctly 3");

        await pool.withdrawReward();
        assert.equal((await weth2.balanceOf(accounts[0])).toString(), ether.toString(), "Reward not paid out");

        await pool.withdrawStake(ether);
        assert.equal((await weth.balanceOf(accounts[0])).toString(), ether.toString(), "Stake Withdrawal not paid out");

        await pool.withdrawAll({from: accounts[1]});
        assert.equal((await weth.balanceOf(accounts[1])).toString(), ether.mul(2).toString(), "Reward not paid out withdrawAll()")
        assert.equal((await weth2.balanceOf(accounts[1])).toString(), ether.toString(), "Stake Withdrawal not paid out withdrawAll()")

    })

})