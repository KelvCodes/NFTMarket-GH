// Import the HDWalletProvider to sign transactions for addresses derived from a mnemonic
const HDWalletProvider = require('truffle-hdwallet-provider');

// Import web3 to interact with the Ethereum blockchain
const web3 = require('web3');

// Load environment variables
const MNEMONIC = process.env.MNEMONIC; // Wallet mnemonic (used to derive addresses)
const INFURA_KEY = process.env.INFURA_KEY; // Infura API key to connect to the Ethereum network
const LOOTBOX_CONTRACT_ADDRESS = process.env.LOOTBOX_CONTRACT_ADDRESS; // Deployed LootBox contract address
const OWNER_ADDRESS = process.env.OWNER_ADDRESS; // Wallet address that will perform the transaction
const NETWORK = process.env.NETWORK; // Target network (e.g., mainnet, rinkeby)

// Ensure all required environment variables are set
if (!MNEMONIC || !INFURA_KEY || !OWNER_ADDRESS || !NETWORK) {
  console.error(
    'Please set a mnemonic, infura key, owner, network, and contract address.'
  );
  return;
}

// Define the ABI (Application Binary Interface) for the LootBox contract
// This ABI only includes the "unpack" method we want to call
const LOOTBOX_ABI = [
  {
    constant: false,
    inputs: [
      {
        internalType: 'uint256',
        name: '_optionId',
        type: 'uint256',
      },
      {
        internalType: 'address',
        name: '_toAddress',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: '_amount',
        type: 'uint256',
      },
    ],
    name: 'unpack',
    outputs: [],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function',
  },
];

/**
 * Main function to interact with the smart contract.
 * In this case, it calls the `unpack` function on the LootBox contract.
 */
async function main() {
  // Determine network URL based on environment input
  const network =
    NETWORK === 'mainnet' || NETWORK === 'live' ? 'mainnet' : 'rinkeby';

  // Initialize the provider with the mnemonic and Infura endpoint
  const provider = new HDWalletProvider(
    MNEMONIC,
    `https://${network}.infura.io/v3/${INFURA_KEY}`
  );

  // Create a web3 instance using the provider
  const web3Instance = new web3(provider);

  // Ensure a contract address was provided
  if (!LOOTBOX_CONTRACT_ADDRESS) {
    console.error('Please set a LootBox contract address.');
    return;
  }

  // Create a contract instance with the ABI and contract address
  const factoryContract = new web3Instance.eth.Contract(
    LOOTBOX_ABI,
    LOOTBOX_CONTRACT_ADDRESS
  );

  try {
    // Call the `unpack` function on the contract
    // Parameters: optionId = 0, recipient = OWNER_ADDRESS, amount = 1
    const result = await factoryContract.methods
      .unpack(0, OWNER_ADDRESS, 1)
      .send({ from: OWNER_ADDRESS, gas: 100000 }); // Estimate or adjust gas as needed

    // Log the transaction hash for reference
    console.log('Unpacked successfully. Transaction: ' + result.transactionHash);
  } catch (error) {
    // Catch and log any errors during contract interaction
    console.error('An error occurred while unpacking the lootbox:', error);
  }
}

// Run the main function
main();

