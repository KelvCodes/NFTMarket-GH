// Import required dependencies
const HDWalletProvider = require("truffle-hdwallet-provider");
const web3 = require("web3");

// Load environment variables
const MNEMONIC = process.env.MNEMONIC;
const NODE_API_KEY = process.env.INFURA_KEY || process.env.ALCHEMY_KEY;
const isInfura = !!process.env.INFURA_KEY; // Determine if Infura is used
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;

// Number of NFTs and lootboxes to mint
const NUM_CREATURES = 12;
const NUM_LOOTBOXES = 4;

// Option IDs for minting via factory
const DEFAULT_OPTION_ID = 0;
const LOOTBOX_OPTION_ID = 2;

// Ensure required environment variables are set
if (!MNEMONIC || !NODE_API_KEY || !OWNER_ADDRESS || !NETWORK) {
  console.error(
    "Please set a mnemonic, Alchemy/Infura key, owner, network, and contract address."
  );
  return;
}

// ABI for directly minting NFTs
const NFT_ABI = [
  {
    constant: false,
    inputs: [
      { name: "_to", type: "address" },
    ],
    name: "mintTo",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
];

// ABI for factory contract minting with option ID
const FACTORY_ABI = [
  {
    constant: false,
    inputs: [
      { name: "_optionId", type: "uint256" },
      { name: "_toAddress", type: "address" },
    ],
    name: "mint",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
];

async function main() {
  // Set the Ethereum network (defaults to rinkeby if not mainnet/live)
  const network =
    NETWORK === "mainnet" || NETWORK === "live" ? "mainnet" : "rinkeby";

  // Create a provider using the mnemonic and Infura/Alchemy endpoint
  const provider = new HDWalletProvider(
    MNEMONIC,
    isInfura
      ? `https://${network}.infura.io/v3/${NODE_API_KEY}`
      : `https://eth-${network}.alchemyapi.io/v2/${NODE_API_KEY}`
  );

  // Initialize web3 instance with the provider
  const web3Instance = new web3(provider);

  // --- FACTORY CONTRACT MINTING LOGIC ---
  if (FACTORY_CONTRACT_ADDRESS) {
    const factoryContract = new web3Instance.eth.Contract(
      FACTORY_ABI,
      FACTORY_CONTRACT_ADDRESS,
      { gasLimit: "1000000" }
    );

    // Mint multiple creatures using DEFAULT_OPTION_ID
    for (let i = 0; i < NUM_CREATURES; i++) {
      const result = await factoryContract.methods
        .mint(DEFAULT_OPTION_ID, OWNER_ADDRESS)
        .send({ from: OWNER_ADDRESS });
      console.log("Minted creature. Transaction: " + result.transactionHash);
    }

    // Mint multiple lootboxes using LOOTBOX_OPTION_ID
    for (let i = 0; i < NUM_LOOTBOXES; i++) {
      const result = await factoryContract.methods
        .mint(LOOTBOX_OPTION_ID, OWNER_ADDRESS)
        .send({ from: OWNER_ADDRESS });
      console.log("Minted lootbox. Transaction: " + result.transactionHash);
    }

  // --- DIRECT NFT CONTRACT MINTING LOGIC ---
  } else if (NFT_CONTRACT_ADDRESS) {
    const nftContract = new web3Instance.eth.Contract(
      NFT_ABI,
      NFT_CONTRACT_ADDRESS,
      { gasLimit: "1000000" }
    );

    // Mint NFTs directly to the owner
    for (let i = 0; i < NUM_CREATURES; i++) {
      const result = await nftContract.methods
        .mintTo(OWNER_ADDRESS)
        .send({ from: OWNER_ADDRESS });
      console.log("Minted creature. Transaction: " + result.transactionHash);
    }

  // --- ERROR HANDLING ---
  } else {
    console.error(
      "Add NFT_CONTRACT_ADDRESS or FACTORY_CONTRACT_ADDRESS to the environment variables"
    );
  }
}

// Run the minting process
main();

