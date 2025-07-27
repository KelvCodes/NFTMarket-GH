
  return
}

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
]

/**
 * For now, this script just opens a lootbox.
 */
async function main() {
  const network =
    NETWORK === 'mainnet' || NETWORK === 'live' ? 'mainnet' : 'rinkeby'
  const provider = new HDWalletProvider(
    MNEMONIC,
    `https://${network}.infura.io/v3/${INFURA_KEY}`
  )
  const web3Instance = new web3(provider)

  if (!LOOTBOX_CONTRACT_ADDRESS) {
    console.error('Please set a LootBox contract address.')
    return
  }

  const factoryContract = new web3Instance.eth.Contract(
    LOOTBOX_ABI,
    LOOTBOX_CONTRACT_ADDRESS
  )
  const result = await factoryContract.methods
    .unpack(0, OWNER_ADDRESS, 1)
    .send({ from: OWNER_ADDRESS, gas: 100000 })
  console.log('Created. Transaction: ' + result.transactionHash)
}

main()
