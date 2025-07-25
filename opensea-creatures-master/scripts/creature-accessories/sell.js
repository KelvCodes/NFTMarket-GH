// Import the required modules from OpenSea JS SDK and web3-provider-engine
const opensea = require('opensea-js');
const { WyvernSchemaName } = require('opensea-js/lib/types');
const OpenSeaPort = opensea.OpenSeaPort;
const Network = opensea.Network;

const { MnemonicWalletSubprovider } = require('@0x/subproviders');
const RPCSubprovider = require('web3-provider-engine/subproviders/rpc');
const Web3ProviderEngine = require('web3-provider-engine');

// Load environment variables
const MNEMONIC = process.env.MNEMONIC;
const INFURA_KEY = process.env.INFURA_KEY;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;
const API_KEY = process.env.API_KEY || ''; // Optional OpenSea API Key

// Validate that all necessary environment variables are set
if (!MNEMONIC || !INFURA_KEY || !NETWORK || !OWNER_ADDRESS) {
  console.error(
    'Please set a mnemonic, infura key, owner, network, API key, nft contract, and factory contract address.'
  );
  return;
}

if (!NFT_CONTRACT_ADDRESS) {
  console.error('Please set an NFT contract address.');
  return;
}

// Set the derivation path for Ethereum wallets
const BASE_DERIVATION_PATH = `44'/60'/0'/0`;

// Create a wallet provider from mnemonic phrase
const mnemonicWalletSubprovider = new MnemonicWalletSubprovider({
  mnemonic: MNEMONIC,
  baseDerivationPath: BASE_DERIVATION_PATH,
});

// Define which network to use (mainnet or testnet like rinkeby)
const network = NETWORK === 'mainnet' || NETWORK === 'live' ? 'mainnet' : 'rinkeby';

// Set the RPC provider using Infura
const infuraRpcSubprovider = new RPCSubprovider({
  rpcUrl: `https://${network}.infura.io/v3/${INFURA_KEY}`,
});

// Create and configure a Web3 provider engine
const providerEngine = new Web3ProviderEngine();
providerEngine.addProvider(mnemonicWalletSubprovider);
providerEngine.addProvider(infuraRpcSubprovider);
providerEngine.start();

// Initialize OpenSea SDK instance
const seaport = new OpenSeaPort(
  providerEngine,
  {
    networkName: NETWORK === 'mainnet' || NETWORK === 'live' ? Network.Main : Network.Rinkeby,
    apiKey: API_KEY,
  },
  (arg) => console.log(arg) // Optional event logger
);

async function main() {
  try {
    console.log('Auctioning an item for a fixed price...');

    // Create a fixed-price sell order for an NFT (tokenId = 1)
    const fixedPriceSellOrder = await seaport.createSellOrder({
      asset: {
        tokenId: '1',
        tokenAddress: NFT_CONTRACT_ADDRESS,
        schemaName: WyvernSchemaName.ERC1155,
      },
      startAmount: 0.05, // Price in ETH
      expirationTime: 0, // Never expires
      accountAddress: OWNER_ADDRESS,
    });

    console.log(
      `✅ Fixed-price sell order created: ${fixedPriceSellOrder.asset.openseaLink}\n`
    );

    console.log('Dutch auctioning an item...');

    // Set an expiration time (24 hours from now)
    const expirationTime = Math.round(Date.now() / 1000 + 60 * 60 * 24);

    // Create a Dutch auction sell order (tokenId = 2)
    const dutchAuctionSellOrder = await seaport.createSellOrder({
      asset: {
        tokenId: '2',
        tokenAddress: NFT_CONTRACT_ADDRESS,
        schemaName: WyvernSchemaName.ERC1155,
      },
      startAmount: 0.05, // Start price
      endAmount: 0.01, // End price after auction
      expirationTime: expirationTime,
      accountAddress: OWNER_ADDRESS,
    });

    console.log(
      `✅ Dutch auction sell order created: ${dutchAuctionSellOrder.asset.openseaLink}\n`
    );

    console.log('Selling multiple items for an ERC20 token (WETH)...');

    // Define WETH token address based on network
    const wethAddress =
      NETWORK === 'mainnet' || NETWORK === 'live'
        ? '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2' // Mainnet WETH
        : '0xc778417E063141139Fce010982780140Aa0cD5Ab'; // Rinkeby WETH

    // Create a sell order for multiple items (tokenId = 3), paid in WETH
    const englishAuctionSellOrder = await seaport.createSellOrder({
      asset: {
        tokenId: '3',
        tokenAddress: NFT_CONTRACT_ADDRESS,
        schemaName: WyvernSchemaName.ERC1155,
      },
      startAmount: 0.03, // Start price in WETH
      quantity: 2, // Number of tokens to sell
      expirationTime: expirationTime,
      paymentTokenAddress: wethAddress,
      accountAddress: OWNER_ADDRESS,
    });

    console.log(
      `✅ Bulk-item sell order created: ${englishAuctionSellOrder.asset.openseaLink}\n`
    );
  } catch (error) {
    console.error('❌ An error occurred during the order creation process:', error);
  }
}

// Execute the main function
main();
