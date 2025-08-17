

// Load sensitive configuration from environment variables
const MNEMONIC = process.env.MNEMONIC;
const NODE_API_KEY = process.env.INFURA_KEY || process.env.ALCHEMY_KEY;
const isInfura = !!process.env.INFURA_KEY; // Detect if Infura is used
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK; // 'mainnet' or 'rinkeby'
const API_KEY = process.env.API_KEY || ""; // Optional OpenSea API key

// Auction configuration values
const DUTCH_AUCTION_OPTION_ID = "1";
const DUTCH_AUCTION_START_AMOUNT = 100; // Starting ETH price for Dutch auction
const DUTCH_AUCTION_END_AMOUNT = 50;    // Ending ETH price for Dutch auction
const NUM_DUTCH_AUCTIONS = 3;           // Number of Dutch auctions to create

const FIXED_PRICE_OPTION_ID = "2";
const FIXED_PRICE = 0.05;               // ETH price for fixed price auctions
const NUM_FIXED_PRICE_AUCTIONS = 10;    // Number of fixed price auctions to create

// Check if all required environment variables are set
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

// Define base derivation path for HD wallet (Ethereum standard)
const BASE_DERIVATION_PATH = `44'/60'/0'/0`;

// Create wallet subprovider from mnemonic
const mnemonicWalletSubprovider = new MnemonicWalletSubprovider({
  mnemonic: MNEMONIC,
  baseDerivationPath: BASE_DERIVATION_PATH,
});

// Choose correct RPC URL depending on provider (Infura or Alchemy)
const network = NETWORK === "mainnet" || NETWORK === "live" ? "mainnet" : "rinkeby";
const rpcUrl = isInfura
  ? `https://${network}.infura.io/v3/${NODE_API_KEY}`
  : `https://eth-${network}.alchemyapi.io/v2/${NODE_API_KEY}`;

// RPC subprovider to connect to Ethereum network
const infuraRpcSubprovider = new RPCSubprovider({ rpcUrl });

// Combine providers into a provider engine
const providerEngine = new Web3ProviderEngine();
providerEngine.addProvider(mnemonicWalletSubprovider);
providerEngine.addProvider(infuraRpcSubprovider);
providerEngine.start(); // Start the engine

// Initialize OpenSea SDK (OpenSeaPort) with provider and network configuration
const seaport = new OpenSeaPort(
  providerEngine,
  {
    networkName: NETWORK === "mainnet" || NETWORK === "live" ? Network.Main : Network.Rinkeby,
    apiKey: API_KEY, // Optional but helps avoid rate limits
  },
  (log) => console.log(log) // Optional logger
);

// Main async function to create multiple auctions
async function main() {
  try {
    console.log("🚀 Starting auction creation script...\n");

    // ✅ Example 1: Create multiple fixed price sell orders for the same option
    console.log("Creating fixed price auctions...");
    const fixedSellOrders = await seaport.createFactorySellOrders({
      assets: [
        {
          tokenId: FIXED_PRICE_OPTION_ID,
          tokenAddress: FACTORY_CONTRACT_ADDRESS,
        },
      ],
      accountAddress: OWNER_ADDRESS,
      startAmount: FIXED_PRICE,
      numberOfOrders: NUM_FIXED_PRICE_AUCTIONS,
    });

    console.log(
      `✅ Successfully created ${fixedSellOrders.length} fixed-price sell orders!\nExample link: ${fixedSellOrders[0].asset.openseaLink}\n`
    );

    // ✅ Example 2: Create fixed price auctions for different options
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

    // ✅ Example 3: Create Dutch auctions with decreasing price over time
    console.log("Creating Dutch auctions...");

    // Expiration time: set to 24 hours from now
    const expirationTime = Math.round(Date.now() / 1000 + 60 * 60 * 24);

    const dutchSellOrders = await seaport.createFactorySellOrders({
      assets: [
        {
          tokenId: DUTCH_AUCTION_OPTION_ID,
          tokenAddress: FACTORY_CONTRACT_ADDRESS,
        },
      ],
      accountAddress: OWNER_ADDRESS,
      startAmount: DUTCH_AUCTION_START_AMOUNT,
      endAmount: DUTCH_AUCTION_END_AMOUNT,
      expirationTime: expirationTime,
      numberOfOrders: NUM_DUTCH_AUCTIONS,
    });

    console.log(
      `✅ Successfully created ${dutchSellOrders.length} Dutch-auction sell orders!\nExample link: ${dutchSellOrders[0].asset.openseaLink}\n`
    );

    console.log("🎉 All auctions created successfully!");
  } catch (error) {
    console.error("❌ Error while creating orders:", error);
  }
}

// Run the script
main();
