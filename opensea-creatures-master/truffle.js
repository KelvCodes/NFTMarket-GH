/**
 * Truffle Configuration File (truffle-config.js)
 *
 * This configuration defines networks, compiler settings, plugins,
 * and external service integrations (Infura, Alchemy, Etherscan, etc.)
 * for deploying, testing, and verifying Ethereum smart contracts.
 */

// Import HDWalletProvider to sign transactions using a wallet mnemonic (seed phrase)
const HDWalletProvider = require("truffle-hdwallet-provider");

// -------------------- Environment Variables --------------------

// Your wallet seed phrase (used by HDWalletProvider to sign transactions)
const MNEMONIC = process.env.MNEMONIC;

// Node provider API key (either Infura or Alchemy)
const NODE_API_KEY = process.env.INFURA_KEY || process.env.ALCHEMY_KEY;

// Flag to check if Infura is being used (true if INFURA_KEY exists)
const isInfura = !!process.env.INFURA_KEY;

// Determine if the current npm script actually needs a remote node (Rinkeby or Mainnet)
// This prevents unnecessary checks for local deployments
const needsNodeAPI =
  process.env.npm_config_argv &&
  (process.env.npm_config_argv.includes("rinkeby") ||
    process.env.npm_config_argv.includes("live"));

// -------------------- Error Handling --------------------

// Exit the process if required values are missing for remote deployments
if ((!MNEMONIC || !NODE_API_KEY) && needsNodeAPI) {
  console.error("❌ Please set a MNEMONIC and either an ALCHEMY_KEY or INFURA_KEY.");
  process.exit(0);
}

// -------------------- Node URLs --------------------

// Construct the node URLs dynamically based on which provider is used
// Infura and Alchemy have different URL formats
const rinkebyNodeUrl = isInfura
  ? `https://rinkeby.infura.io/v3/${NODE_API_KEY}`
  : `https://eth-rinkeby.alchemyapi.io/v2/${NODE_API_KEY}`;

const mainnetNodeUrl = isInfura
  ? `https://mainnet.infura.io/v3/${NODE_API_KEY}`
  : `https://eth-mainnet.alchemyapi.io/v2/${NODE_API_KEY}`;

// -------------------- Truffle Export --------------------

module.exports = {
  networks: {
    /**
     * Local Development Network
     * Usually powered by Ganache (GUI or CLI).
     * This allows you to test contracts locally before deploying to testnets.
     */
    development: {
      host: "127.0.0.1",  // Localhost address
      port: 7545,         // Default Ganache port
      gas: 5000000,       // Max gas for transactions
      network_id: "*",    // Accepts any network ID (wildcard)
    },

    /**
     * Rinkeby Test Network
     * Used for testing contracts on Ethereum’s Rinkeby testnet.
     * Requires Infura or Alchemy + wallet mnemonic for signing.
     */
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(MNEMONIC, rinkebyNodeUrl);
      },
      gas: 5000000,       // Gas limit per transaction
      network_id: 4,      // Rinkeby's official network ID
    },

    /**
     * Ethereum Mainnet (Production)
     * Used for real deployments on Ethereum’s live network.
     * ⚠️ Be cautious — transactions here cost real ETH.
     */
    live: {
      provider: function () {
        return new HDWalletProvider(MNEMONIC, mainnetNodeUrl);
      },
      gas: 5000000,       // Gas limit (must not exceed block limit)
      gasPrice: 5000000000, // 5 Gwei (set appropriately depending on network congestion)
      network_id: 1,      // Mainnet’s official network ID
    },
  },

  // -------------------- Testing Configuration --------------------
  mocha: {
    // Gas reporter helps track the gas usage per test
    reporter: "eth-gas-reporter",
    reporterOptions: {
      currency: "USD",   // Show costs in USD
      gasPrice: 2,       // Gas price to use for cost estimates (in Gwei)
    },
  },

  // -------------------- Solidity Compiler Configuration --------------------
  compilers: {
    solc: {
      version: "^0.8.0", // Solidity version range
      settings: {
        optimizer: {
          enabled: true, // Enable optimization for smaller bytecode
          runs: 20,      // Optimize for contracts executed ~20 times
        },
      },
    },
  },

  // -------------------- Truffle Plugins --------------------
  plugins: [
    'truffle-plugin-verify', // Plugin for verifying contracts on Etherscan
  ],

  // -------------------- API Keys --------------------
  api_keys: {
    // Replace with your actual Etherscan API key to enable contract verification
    etherscan: process.env.ETHERSCAN_API_KEY || 'ETHERSCAN_API_KEY_FOR_VERIFICATION',
  },
};

