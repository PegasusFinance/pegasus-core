import chai from "chai";
import { ethers, waffle } from "hardhat";
import { BigNumber, Contract, Wallet, Signer } from 'ethers';
import { deployMockContract } from '@ethereum-waffle/mock-contract';
import { ContractFactory } from "@ethersproject/contracts";

const { deployContract } = waffle
const { expect } = chai

import { Controller, ControllerFactory, IUniswapV2RouterMockFactory, MintableErc20Factory, PegasusPool, PegasusPoolFactory, PegasusTokenFactory, RewardSplitter, RewardSplitterFactory, 
    WETH, WETHFactory, MintableErc20, IUniswapV2RouterMock, EthPoolFactory, EthPool, BunnySingleLiquidityStrategy } from '../typechain';
const constants = require("../migrations/config.js");

const IERC20 = require("../build/contracts/IERC20.json");
const IUniswap = require("../build/contracts/IUniswapV2Router01.json");
const IBunnyVault = require("../build/contracts/IBunnyVault.json");
const IPool = require("../build/contracts/IPool.json");
const IRewardSplitter = require("../build/contracts/RewardSplitter.json");

import WETHArtifact from "../artifacts_hardhat/contracts/core/WETH.sol/WETH.json";
import ControllerArtifact from "../artifacts_hardhat/contracts/core/Controller.sol/Controller.json";
const BunnySingleLiquidityStrategyFactory= require("../typechain/BunnySingleLiquidityStrategyFactory");

// chai.use(solidity);

describe('Integration', () => {
    
    let signers : Signer[];
    let signer1 : Signer;
    let wallet1 : Wallet;
    let wallets : Wallet[]

    let weth: WETH;
    let controller: Controller;

    beforeEach(async () => {

        signers = await ethers.getSigners();
        signer1 = signers[0];
        wallet1 = <Wallet>signers[0]
        wallets = signers.map(x => <Wallet>x);

        weth = await deployContract(wallet1, WETHArtifact, []) as WETH;
        for (let i = 0; i < wallets.length / 2 ; i++) {
            await weth.connect(wallets[i]).deposit({value: ether(100)});
            // console.log((await weth.balanceOf(wallets[i].address)).toString())
        }
        
        controller = await deployContract(wallet1, ControllerArtifact, []) as Controller;
        await controller.updateFeeCollector(wallets[2].address);
    })

    it2("Integration 1", async () => {

        console.log("Starting Integration Test")

        const pegFactory = (await ethers.getContractFactory("PegasusToken", signers[0])) as PegasusTokenFactory;
        let peg = await pegFactory.deploy();
        let wbnb = await deploy<MintableErc20Factory, MintableERC20>("MintableERC20", signers[0], ["WBNB", "WBNB"]);
        // let wbnbmock = await deployMockContract(wallet1, IERC20.abi);
        // let uniswapmock = await deployMockContract(wallet1, IUniswap.abi);
        // let uniswapPoolmock = await deployMockContract(wallet1, IERC20.abi);
        let uniswapPoolmock = await deploy<MintableErc20Factory, MintableERC20>("MintableERC20", signers[0], ["UNIP", "UNIP"])
        console.log([uniswapPoolmock.address, weth.address, wbnb.address, peg.address])
        let uniswapmock = await deploy<IUniswapV2RouterMockFactory, IUniswapV2RouterMock>("IUniswapV2RouterMock", signer1, [uniswapPoolmock.address, weth.address, wbnb.address, peg.address]); //uniswapPoolmock.address, 
        let bunnyvaultmock = await deployMockContract(wallet1, IBunnyVault.abi);

        // await wbnbmock.mock.approve.returns(true);
        // await uniswapPoolmock.mock.approve.returns(true);
        console.log("Mocks Deployed")

        //Add some PEG into PEG-Pool
        let pegPool = await deploy<PegasusPoolFactory, PegasusPool>("PegasusPool", signer1, [peg.address, uniswapPoolmock.address, wbnb.address, uniswapmock.address])
        //Test Whitelist and Minting
        console.log("Adding Member")
        await peg.addMember(wallet1.address);
        expect(await peg.isMember(wallet1.address)).to.equal(true);
        console.log("Minting");
        await peg.mintFor(wallet1.address, ether(10));
        await peg.mintFor(uniswapmock.address, ether(10000));
        expect(await peg.balanceOf(wallet1.address)).to.eq(ether(10));
        
        await peg.approve(pegPool.address, ether(100000))
        await pegPool.depositStake(ether(10))

        console.log("Deposited Stake")

        expect(await peg.balanceOf(wallet1.address)).to.eq(0);
        expect(await pegPool.stake(wallet1.address)).to.eq(ether(10));


        //Mock Pancakeswap, Bunny-Pool
        await bunnyvaultmock.mock.deposit.returns();

        let ethPool = await deployMockContract(wallet1, IPool.abi);
        await ethPool.mock.token.returns(weth.address);
        await ethPool.mock.totalSupply.returns(0);
        await controller.addPool(ethPool.address);

        //Init Controller
        await controller.updateBuybackSplit(ethPool.address, 800000);
        await controller.updateInterestFee(ethPool.address, 300000);

        //Invest into ETHPool
        //Check correct ETHPool values (balance, etc.)
        //Check correct Strategy values
        //Let Time pass

        //Mock PEG-BNB Pool (addLiquidity)
        //WithdrawAll
        //Check correct Fee Distribution (Dev, Liquidity Addition), PEG-Token Minting, PEG-Pool Distribution
        
        //Perform Performance Fee Distribution
        let splitter = await deploy<RewardSplitterFactory, RewardSplitter>("RewardSplitter", signer1, [controller.address, uniswapmock.address, pegPool.address, wbnb.address, peg.address]);
        // await wbnb['mint(address,uint256)'](wallet1.address, ether(10));
        // await wbnb.transfer(splitter.address, ether(10));
        await peg.addMember(splitter.address);
        await weth.deposit({value: ether(10)})
        await weth.transfer(splitter.address, ether(10));

        console.log("Starting Feepaid")

        // await uniswapmock.mock.swapExactTokensForTokens.returns(0, 0, 20);
        // await uniswapmock.mock.addLiquidity.withArgs(wbnb.address, )

        await splitter.feePaid(ethPool.address, ether(10));

        //Check results

        expect(await peg.balanceOf(ethPool.address)).to.eq(ether("80"))
        expect(await pegPool.reward(wallet1.address)).to.eq(ether("800"))
        expect(await weth.balanceOf(uniswapmock.address)).to.eq(ether("10"))
        expect(await wbnb.balanceOf(uniswapmock.address)).to.eq(ether("16")); //4 * 2 + 8 als Liquidity
        expect(await uniswapPoolmock.balanceOf(pegPool.address)).to.eq(ether("800"));

        expect(await wbnb.balanceOf(wallets[2].address)).to.eq(ether("4")); //Dev Acccount
    })

    it("Test ETHPool & Strategy", async () => {

        const pegFactory = (await ethers.getContractFactory("PegasusToken", signers[0])) as PegasusTokenFactory;
        let peg = await pegFactory.deploy();

        let ethPool = await deploy<EthPoolFactory, EthPool>("ETHPool", signers[0], [controller.address, weth.address, peg.address]);
        await controller.addPool(ethPool.address);

        let wbnb = await deploy<MintableErc20Factory, MintableErc20>("MintableERC20", signers[0], ["WBNB", "WBNB"]);
        let uniswapPoolmock = await deploy<MintableErc20Factory, MintableErc20>("MintableERC20", signers[0], ["UNIP", "UNIP"])
        let uniswapmock = await deploy<IUniswapV2RouterMockFactory, IUniswapV2RouterMock>("IUniswapV2RouterMock", signer1, [uniswapPoolmock.address, weth.address, wbnb.address, peg.address]); //uniswapPoolmock.address, 

        let bunnyvaultmock = await deployMockContract(wallet1, IBunnyVault.abi);
        // bunnyvaultmock.mock.
        let rewardSplitterMock = await deployMockContract(wallet1, IRewardSplitter.abi);
        await rewardSplitterMock.mock.feePaid.returns();

        //address _controller, address _pool, address _bunnypool, address _router, address _rewardSplitter
        let bunnyStrat = await deploy<typeof BunnySingleLiquidityStrategyFactory, BunnySingleLiquidityStrategy>("BunnySingleLiquidityStrategy", signers[0], 
        [controller.address, ethPool.address, bunnyvaultmock.address, uniswapmock.address, rewardSplitterMock.address]);

        await controller.updateStrategy(ethPool.address, bunnyStrat.address);

        await bunnyvaultmock.mock.earned.returns(0);
        await bunnyvaultmock.mock.principalOf.returns(ether(0));
        await bunnyvaultmock.mock.deposit.returns();

        await ethPool["deposit()"]({value: ether(1)})

        expect(await ethPool.balanceOf(wallet1.address)).eq(ether(1))
        expect(await weth.balanceOf(bunnyStrat.address)).eq(ether(1))
        await weth.transferFromTest(bunnyStrat.address, bunnyvaultmock.address, ether(1));

        await bunnyvaultmock.mock.principalOf.returns(ether(1));
        await bunnyvaultmock.mock.earned.returns(ether("0.5"));
        let ethPool1 = ethPool.connect(wallets[1]);
        await ethPool1["deposit()"]({value: ether(1)})

        expect((await ethPool.balanceOf(wallets[1].address)).div(10000).toNumber()).approximately(ether(1 / (1 + 0.5 * 0.7)).div(10000).toNumber(), ether(1).div(10000000).toNumber())

    })
})

async function deploy<F extends ContractFactory, V extends Contract>(name: string, signer: Signer, args: any[]) : Promise<V>{
    const pegFactory = ((await ethers.getContractFactory(name, signer)) as unknown) as F;
    let x = (await pegFactory.deploy(...args)) as unknown as V;
    await x.deployed()
    return x
}

function it2(s: string, x: any){

}

function ether(s: string|number) : BigNumber{
    return ethers.utils.parseEther(s.toString());
}