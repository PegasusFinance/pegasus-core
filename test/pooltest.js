const Controller = artifacts.require("Controller");
const ETHPool = artifacts.require("ETHPool");
const WETH = artifacts.require("WETH");
const SampleStrategy = artifacts.require("SampleStrategy");
const { ethers } = require("ethers");

let ethersProvider = new ethers.providers.Web3Provider(web3.currentProvider);

const feeCollector = "0x11923d873e2030d45aCe9cfc63B12257205Ee609";

contract('Controller', function(accounts) {

    let c;
    let pool;
    let weth = null;
    let strat;

    it("Should have addresses", async () => {

        c = await Controller.deployed();
        pool = await ETHPool.deployed();
        weth = await WETH.deployed();
        strat = await SampleStrategy.deployed();

        assert.equal(c.address.length, 42, "Address of Controller not right");
        assert.equal(pool.address.length, 42, "Address of ETHPool not right");
        assert.equal(weth.address.length, 42, "Address of WETH not right");
        assert.equal(strat.address.length, 42, "Address of Strategy not right");

        labels[c.address] = "Controller";
        labels[pool.address] = "ETHPool";
        labels[weth.address] = "WETH";
        labels[strat.address] = "SampleStrategy";
        labels[feeCollector] = "FeeCollector";
        labels[accounts[0]] = "Account 0";

    });

    it("Test Deposit with ETH", async () => {

        // let all = await weth.allowance(pool.address, strat.address);
        // console.log(all.toString());

        // console.log(pool);
        let res = await pool.methods["deposit()"]({value: ethers.utils.parseEther('1')});
        console.log(accounts[0]);
        let balance = await pool.balanceOf(accounts[0]);
        assert.equal(balance.toString(), ethers.utils.parseEther('1').toString(), "Token not minted correctly")

        let wethBalance = await web3.eth.getBalance(weth.address);
        assert.equal(wethBalance.toString(), ethers.utils.parseEther('1').toString(), "Weth has not recieved Ether");

        wethBal = await weth.balanceOf(strat.address);
        assert.equal(wethBal.toString(), ethers.utils.parseEther('1').toString(), "Strat has not recieved WETH");


        // instance = await Test.new();

        // claimable = await rewardsInstance.claimable("0x11923d873e2030d45aCe9cfc63B12257205Ee609");
        // console.log(claimable.toString())

    })

    it("Test correct values after strategy made money", async () => {

        let priceBefore = await pool.getPricePerShare();
        assert.equal(priceBefore.toString(), ethers.utils.parseEther("1").toString(), "LP Tokenprice not 1");

        await weth.methods["deposit()"]({value: ethers.utils.parseEther("1")});
        await weth.transfer(strat.address, ethers.utils.parseEther("1"));
        // await strat.methods["deposit()"]({value: ethers.utils.parseEther("1")});

        let priceAfter = await pool.getPricePerShare();
        assert.equal(priceAfter.toString(), ethers.utils.parseEther("2").toString(), "LP Tokenprice not 2");

    });

    it("Test correct withdrawal of LP Tokens in WETH", async() => {

        let wethbalbefore = await weth.balanceOf(accounts[0]);
        console.log(wethbalbefore.toString())

        await dumpTokenBalances(weth, [pool.address, accounts[0], strat.address, feeCollector]);
        await dumpTokenBalances(pool, [pool.address, accounts[0], strat.address, feeCollector]);

        await pool.withdraw(ethers.utils.parseEther("0.5"))

        await dumpTokenBalances(weth, [pool.address, accounts[0], strat.address, feeCollector]);
        await dumpTokenBalances(pool, [pool.address, accounts[0], strat.address, feeCollector]);

        let wethbalafter = await weth.balanceOf(accounts[0]);
        console.log(wethbalafter.toString())
        assert.equal(wethbalafter.sub(wethbalbefore).toString(), ethers.utils.parseEther("0.994").toString(), "Not enough WETH payed out")

        let lptokens = await pool.balanceOf(accounts[0]);
        console.log(lptokens.toString())
        assert.equal(lptokens.toString(), ethers.utils.parseEther("0.5").toString(), "LP Tokens no subtracted correctly");
        
    });

    
    it("Test correct withdrawal of LP Tokens in ETH", async() => {

        let totalLocked = await pool.totalValue();
        console.log(ethers.utils.formatEther(ethers.BigNumber.from(totalLocked.toString())));
        
        await weth.methods["deposit()"]({value: totalLocked});
        await weth.transfer(strat.address, totalLocked);

        let ethbefore = await web3.eth.getBalance(accounts[0]);

        await dumpTokenBalances(null, [pool.address, accounts[0], strat.address, feeCollector], true);
        await dumpTokenBalances(pool, [pool.address, accounts[0], strat.address, feeCollector]);

        await pool.withdrawETH(ethers.utils.parseEther("0.25"))

        await dumpTokenBalances(null, [pool.address, accounts[0], strat.address, feeCollector], true);
        await dumpTokenBalances(pool, [pool.address, accounts[0], strat.address, feeCollector]);

        let ethafter = await web3.eth.getBalance(accounts[0]);
        
        //Price
        let price = await pool.getPricePerShare();
        assert.equal(ethers.BigNumber.from(price.toString()).toString(), ethers.utils.parseEther("4").toString(), "Price not correct, should be 4");

        //Amount payed out
        let diff = ethers.BigNumber.from(ethafter).sub(ethers.BigNumber.from(ethbefore))
        assert.equal(diff.lt(ethers.utils.parseEther("0.994")) && diff.gt(ethers.utils.parseEther("0.99")), true, "Not enough ETH payed out")

        let lptokens = await pool.balanceOf(accounts[0]);
        console.log(lptokens.toString())
        assert.equal(lptokens.toString(), ethers.utils.parseEther("0.25").toString(), "LP Tokens no subtracted correctly");
        
    });

})

var labels = {}

async function dumpTokenBalances(token, addresses, isEth = false){
    let table = [[], [], []];
    let name;
    let short;
    if(!isEth){
        name = await token.name();
        short = await token.symbol();
    }else{
        name = "Ether";
        short = "ETH"
    }
    console.log("Token: " + name);
    for (let index = 0; index < addresses.length; index++) {
        let element = addresses[index];
        let bal;
        if(!isEth){
            bal = await token.balanceOf(element);
        }else{
            bal = await web3.eth.getBalance(element);
        }
        table[2].push(ethers.utils.formatEther(ethers.utils.parseUnits(bal.toString(), "wei")) + " " + short);
        table[0].push(element);
        table[1].push(labels[element]);
    }
    console.table(table);
}