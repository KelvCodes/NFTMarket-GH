// --------------------------- IMPORT DEPENDENCIES ---------------------------
// Import OpenSea SDK (opensea-js) for interacting with OpenSea marketplace
const opensea = require("opensea-js");
const OpenSeaPort = opensea.OpenSeaPort; // Main entry class for the SDK
const Network = opensea.Network;         // Enum for selecting Ethereum networks

// Import wallet and provider dependencies
const MnemonicWalletSubprovider = require("@0x/subproviders").MnemonicWalletSubprovider; // For mnemonic-based wallet
const RPCSubprovider = require("web3-provider-engine/subproviders/rpc");                 // For connecting to Ethereum RPC
const Web3ProviderEngine = require("web3-provider-engine");                             // Combines subproviders

// --------------------------- LOAD ENVIRONMENT VARIABLES ---------------------------
// These values should be securely stored in a `.env` file
const MNEMONIC = process.env.MNEMONIC;                        // Wallet seed phrase
const NODE_API_KEY = process.env.INFURA_KEY || process.env.ALCHEMY_KEY; // RPC provider key
const isInfura = !!process.env.INFURA_KEY;                    // Flag: true if Infura is used, false if Alchemy
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS; // NFT Factory contract address
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;              // Wallet address of NFT owner/creator
const NETWORK = process.env.NETWORK;                          // "mainnet" or "rinkeby" (testnet)
const API_KEY = process.env.API_KEY || "";                    // Optional OpenSea API key (avoids rate limits)

// --------------------------- AUCTION CONFIGURATION ---------------------------
// Configuration for Dutch auctions
const DUTCH_AUCTION_OPTION_ID = "1";       // Token ID in the factory contract
const DUTCH_AUCTION_START_AMOUNT = 100;    // Starting ETH price
const DUTCH_AUCTION_END_AMOUNT = 50;       // Ending ETH price after duration
const NUM_DUTCH_AUCTIONS = 3;              // Number of Dutch auctions to create

// Configuration for Fixed price sales
const FIXED_PRICE_OPTION_ID = "2";         // Token ID for fixed price sale
const FIXED_PRICE = 0.05;                  // Fixed price in ETH
const NUM_FIXED_PRICE_AUCTIONS = 10;       // Number of fixed price sales to create

// --------------------------- VALIDATION ---------------------------
// Ensure all required environment variables are provided
if (!MNEMONIC || !NODE_API_KEY || !NETWORK || !OWNER_ADDRESS) {
  console.error(
    "❗ Please set MNEMONIC, Alchemy/Infura key, OWNER_ADDRESS, NETWORK, and API_KEY in environment variables."
  );
  return;
}

if (!FACTORY_CONTRACT_ADDRESS) {
  console.error("❗ Please specify FACTORY_CONTRACT_ADDRESS in environment variables.");
  return;
}

// --------------------------- WALLET & PROVIDER SETUP ---------------------------
// Define HD wallet derivation path (Ethereum standard BIP44 path)
const BASE_DERIVATION_PATH = `44'/60'/0'/0`;

// Create wallet provider using mnemonic phrase
const mnemonicWalletSubprovider = new MnemonicWalletSubprovider({
  mnemonic: MNEMONIC,
  baseDerivationPath: BASE_DERIVATION_PATH,
});

// Select network (mainnet or rinkeby)
const network = NETWORK === "mainnet" || NETWORK === "live" ? "mainnet" : "rinkeby";

// Build correct RPC URL depending on whether Infura or Alchemy is used
const rpcUrl = isInfura
  ? `https://${network}.infura.io/v3/${NODE_API_KEY}`
  : `https://eth-${network}.alchemyapi.io/v2/${NODE_API_KEY}`;

// RPC provider to connect to Ethereum node
const infuraRpcSubprovider = new RPCSubprovider({ rpcUrl });

// Combine wallet and RPC providers into a single provider engine
const providerEngine = new Web3ProviderEngine();
providerEngine.addProvider(mnemonicWalletSubprovider); // Sign transactions
providerEngine.addProvider(infuraRpcSubprovider);      // Send transactions to Ethereum
providerEngine.start(); // Start engine to enable communication

// --------------------------- OPENSEA SDK INITIALIZATION ---------------------------
// Initialize OpenSeaPort (main SDK object) for creating and managing orders
const seaport = new OpenSeaPort(
  providerEngine,
  {
    networkName: NETWORK === "mainnet" || NETWORK === "live" ? Network.Main : Network.Rinkeby,
    apiKey: API_KEY, // Optional but recommended to prevent API rate limiting
  },
  (log) => console.log(log) // Optional logger for debugging
);

// --------------------------- MAIN SCRIPT ---------------------------
// Main function to create multiple auctions (fixed price + Dutch auctions)
async function main() {
  try {
    console.log("🚀 Starting auction creation script...\n");

    // -----------------------------------------------------------------
    // ✅ Example 1: Create multiple fixed-price auctions for SAME option
    // -----------------------------------------------------------------
    console.log("Creating fixed price auctions...");
    const fixedSellOrders = await seaport.createFactorySellOrders({
      assets: [
        {
          tokenId: FIXED_PRICE_OPTION_ID,
          tokenAddress: FACTORY_CONTRACT_ADDRESS,
        },
      ],
      accountAddress: OWNER_ADDRESS, // Address that will own/sell the NFTs
      startAmount: FIXED_PRICE,      // Fixed price in ETH
      numberOfOrders: NUM_FIXED_PRICE_AUCTIONS, // Create multiple at once
    });

    console.log(
      `✅ Successfully created ${fixedSellOrders.length} fixed-price sell orders!\nExample link: ${fixedSellOrders[0].asset.openseaLink}\n`
    );

    // -----------------------------------------------------------------
    // ✅ Example 2: Create fixed-price auctions for DIFFERENT options
    // -----------------------------------------------------------------
    console.log("Creating fixed price auctions for multiple assets...");
    const fixedSellOrdersTwo = await seaport.createFactorySellOrders({
      assets: [
        { tokenId: "3", tokenAddress: FACTORY_CONTRACT_ADDRESS },
        { tokenId: "4", tokenAddress: FACTORY_CONTRACT_ADDRESS },
        { tokenId: "5", tokenAddress: FACTORY_CONTRACT_ADDRESS },
        { tokenId: "6", tokenAddress: FACTORY_CONTRACT_ADDRESS },
      ],
      factoryAddress: FACTORY_CONTRACT_ADDRESS,
      accountAddress: OWNER_ADDRESS,
      startAmount: FIXED_PRICE,
      numberOfOrders: NUM_FIXED_PRICE_AUCTIONS,
    });

    console.log(
      `✅ Successfully created ${fixedSellOrdersTwo.length} fixed-price sell orders for multiple assets!\nExample link: ${fixedSellOrdersTwo[0].asset.openseaLink}\n`
    );

    // -----------------------------------------------------------------
    // ✅ Example 3: Create Dutch auctions (price decreases over time)
    // -----------------------------------------------------------------
    console.log("Creating Dutch auctions...");

    // Set expiration time (24 hours from now, in seconds)
    const expirationTime = Math.round(Date.now() / 1000 + 60 * 60 * 24);

    const dutchSellOrders = await seaport.createFactorySellOrders({
      assets: [
        {
          tokenId: DUTCH_AUCTION_OPTION_ID,
          tokenAddress: FACTORY_CONTRACT_ADDRESS,
        },
      ],
      accountAddress: OWNER_ADDRESS,
      startAmount: DUTCH_AUCTION_START_AMOUNT, // Starting price
      endAmount: DUTCH_AUCTION_END_AMOUNT,     // Ending price
      expirationTime: expirationTime,          // Time when auction ends
      numberOfOrders: NUM_DUTCH_AUCTIONS,      // How many auctions to create
    });

    console.log(
      `✅ Successfully created ${dutchSellOrders.length} Dutch-auction sell orders!\nExample link: ${dutchSellOrders[0].asset.openseaLink}\n`
    );

    console.log("🎉 All auctions created successfully!");
  } catch (error) {
    console.error("❌ Error while creating orders:", error);
  }
}

// --------------------------- RUN SCRIPT ---------------------------
main();

