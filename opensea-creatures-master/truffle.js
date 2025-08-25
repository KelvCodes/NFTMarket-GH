
    reporter: "eth-gas-reporter", // Report gas usage per test
    reporterOptions: {
      currency: "USD",           // Show cost in USD
      gas
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

