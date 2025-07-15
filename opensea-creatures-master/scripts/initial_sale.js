
ry contract address.");
  return;
}

// Define base derivation path for HD wallet (common for Ethereum)
const BASE_DERIVATION_PATH = `44'/60'/0'/0`;

// Set up wallet provider using mnemonic phrase
const mnemonicWalletSubprovider = new MnemonicWalletSubprovider({
  mnemonic: MNEMONIC,
  baseDerivationPath: BASE_DERIVATION_PATH,
});

// Determine which Ethereum network to use
const network = NETWORK === "mainnet" || NETWORK === "live" ? "mainnet" : "rinkeby";

// Set up RPC provider using Infura or Alchemy
const infuraRpcSubprovider = new RPCSubprovider({
  rpcUrl: isInfura
    ? `https://${network}.infura.io/v3/${NODE_API_KEY}`
    : `https://eth-${network}.alchemyapi.io/v2/${NODE_API_KEY}`,
});

// Create and configure provider engine
const providerEngine = new Web3ProviderEngine();
providerEngine.addProvider(mnemonicWalletSubprovider);
providerEngine.addProvider(infuraRpcSubprovider);
providerEngine.start();

// Initialize OpenSea SDK (OpenSeaPort) with the configured provider
const seaport = new OpenSeaPort(
  providerEngine,
  {
    networkName: NETWORK === "mainnet" || NETWORK === "live" ? Network.Main : Network.Rinkeby,
    apiKey: API_KEY, // Optional but useful if making many requests
  },
  (arg) => console.log(arg) // Logger callback (optional)
);

async function main() {
  try {
    // Example 1: Create multiple fixed price sell orders for a single option
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
      `✅ Successfully created ${fixedSellOrders.length} fixed-price sell orders! Example link: ${fixedSellOrders[0].asset.openseaLink}\n`
    );

    // Example 2: Create fixed price sell orders for multiple different options
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
      `✅ Successfully created ${fixedSellOrdersTwo.length} fixed-price sell orders for multiple assets! Example link: ${fixedSellOrdersTwo[0].asset.openseaLink}\n`
    );

    // Example 3: Create Dutch auctions with declining price over time
    console.log("Creating Dutch auctions...");

    // Set expiration time (24 hours from now)
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
      `✅ Successfully created ${dutchSellOrders.length} Dutch-auction sell orders! Example link: ${dutchSellOrders[0].asset.openseaLink}\n`
    );

  } catch (error) {
    console.error("❌ Error while creating orders:", error);
  }
}

// Run the script
main();

