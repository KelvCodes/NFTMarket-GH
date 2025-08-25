

module.exports = {
  networks: {
    // Local development network (usually Ganache)
    development: {
      host: "localhost",     // Localhost IP
      port: 7545,            // Default port for Ganache
      gas: 5000000,          // Max gas for transactions
      network_id: "*",       // Accept any network ID
    },

    // Rinkeby Test Network Configuration
    rinkeby: {
      provider: function () {
        // Use HDWalletProvider with your mnemonic and the Rinkeby node URL
        return new HDWalletProvider(MNEMONIC, rinkebyNodeUrl);
      },
      gas: 5000000,          // Gas limit
      network_id: 4,         // Rinkeby's network ID
    },

    // Ethereum Mainnet Configuration
    live: {
      provider: function () {
        // Use HDWalletProvider with your mnemonic and the Mainnet node URL
        return new HDWalletProvider(MNEMONIC, mainnetNodeUrl);
      },
      gas: 5000000,          // Gas limit for mainnet (ensure it's within the block limit)
      gasPrice: 5000000000,  // Gas price (in wei) — 5 Gwei
      network_id: 1,         // Mainnet network ID
    },
  },

  // Mocha testing configuration
  mocha: {
    reporter: "eth-gas-reporter", // Report gas usage per test
    reporterOptions: {
      currency: "USD",           // Show cost in USD
      gasPrice: 2,               // Gas price used for cost estimation
    },
  },

  // Solidity compiler configuration
  compilers: {
    solc: {
      version: "^0.8.0",         // Use Solidity v0.8.x and above
      settings: {
        optimizer: {
          enabled: true,         // Enable optimizer for smaller contract size
          runs: 20,              // Optimize for contracts that will be run ~20 times
        },
      },
    },
  },

  // Truffle plugins
  plugins: [
    'truffle-plugin-verify',     // Plugin to verify contracts on Etherscan
  ],

  // API keys used for Etherscan contract verification
  api_keys: {
    etherscan: 'ETHERSCAN_API_KEY_FOR_VERIFICATION', // Replace with your actual Etherscan API key
  }
};

