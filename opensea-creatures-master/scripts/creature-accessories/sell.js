cWallet()

const seaport = new OpenSeaPort(
  providerEngine,
  {
    networkName:
      NETWORK === 'mainnet' || NETWORK === 'live'
        ? Network.Main
        : Network.Rinkeby,
    apiKey: API_KEY,
  },
  (arg) => console.log(arg)
)

async function main() {
  // Example: simple fixed-price sale of an item owned by a user.
  console.log('Auctioning an item for a fixed price...')
  const fixedPriceSellOrder = await seaport.createSellOrder({
    asset: {
      tokenId: '1',
      tokenAddress: NFT_CONTRACT_ADDRESS,
      schemaName: WyvernSchemaName.ERC1155,
    },
    startAmount: 0.05,
    expirationTime: 0,
    accountAddress: OWNER_ADDRESS,
  })
  console.log(
    `Successfully created a fixed-price sell order! ${fixedPriceSellOrder.asset.openseaLink}\n`
  )

  // // Example: Dutch auction.
  console.log('Dutch auctioning an item...')
  const expirationTime = Math.round(Date.now() / 1000 + 60 * 60 * 24)
  const dutchAuctionSellOrder = await seaport.createSellOrder({
    asset: {
      tokenId: '2',
      tokenAddress: NFT_CONTRACT_ADDRESS,
      schemaName: WyvernSchemaName.ERC1155,
    },
    startAmount: 0.05,
    endAmount: 0.01,
    expirationTime: expirationTime,
    accountAddress: OWNER_ADDRESS,
  })
  console.log(
    `Successfully created a dutch auction sell order! ${dutchAuctionSellOrder.asset.openseaLink}\n`
  )

  // Example: multiple item sale for ERC20 token
  console.log('Selling multiple items for an ERC20 token (WETH)')
  const wethAddress =
    NETWORK === 'mainnet' || NETWORK === 'live'
      ? '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
      : '0xc778417e063141139fce010982780140aa0cd5ab'
  const englishAuctionSellOrder = await seaport.createSellOrder({
    asset: {
      tokenId: '3',
      tokenAddress: NFT_CONTRACT_ADDRESS,
      schemaName: WyvernSchemaName.ERC1155,
    },
    startAmount: 0.03,
    quantity: 2,
    expirationTime: expirationTime,
    paymentTokenAddress: wethAddress,
    accountAddress: OWNER_ADDRESS,
  })
  console.log(
    `Successfully created bulk-item sell order! ${englishAuctionSellOrder.asset.openseaLink}\n`
  )
}

main()


