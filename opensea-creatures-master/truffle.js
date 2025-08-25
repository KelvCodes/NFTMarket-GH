
    reporter: "eth-gas-reporter", // Report gas usage per test
    reporterOptions: {
      currency: "USD",           // Show cost in USD

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

