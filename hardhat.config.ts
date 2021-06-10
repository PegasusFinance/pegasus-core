import { task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import '@typechain/hardhat'
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

task("accounts", "Prints the list of accounts", async (args, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

export default {
  networks: {
    hardhat: {}
  },
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200000
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts_hardhat"
  },
  mocha: {
    timeout: 200000
  },
  typechain: {
    outDir: "/typechain",
    target: "ethers-v5",
    alwaysGenerateOverloads: false
  }
};
