module.exports = {
  // Uncommenting the defaults below 
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  networks: {
    development: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*"
    },
    local: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      gas: 8000000,//8721975,
    },
    testing: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      gas: 8000000,//8721975,
    },
    ropsten: {
      provider: () => new HDWalletProvider(mnemonics, `https://ropsten.infura.io/v3/${projectId}`),
      network_id: 3,       // Ropsten's id
      gas: 7900000,        // Ropsten has a lower block limit than mainnet
      confirmations: 1,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: false
    },
    develop: {
      defaultEtherBalance: 100000,
      accounts: 20
    },
    main: {
      provider: () => new HDWalletProvider(mnemonics, `https://mainnet.infura.io/v3/${projectId}`),
      network_id: 1,       
      // gas: 12406082,       
      gasPrice: 57000000000,
      confirmations: 1,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: false
    },
    mumbai: {
      provider: () => new HDWalletProvider(pk, `https://rpc-mumbai.matic.today`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    mainnetfork: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      gas: 8000000,
    }
  },
  compilers: {
    solc: {
      version: "0.8.0",  // ex:  "0.4.20". (Default: Truffle's installed solc)
      settings: {
        optimizer: {
          enabled: true,
          runs: 200000
        }
      },
      evmVersion: "istanbul"
    }
  },
  plugins: [
    'truffle-plugin-verify',
    "truffle-contract-size"
  ],
  api_keys: {
    etherscan: 'RDAPXS7UZH1FP2D3JINP171QDKSFQ2FQQP'
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    before_timeout: 1200000,
    reporterOptions: {
      gasPrice: 55
    }
  }
  
};
