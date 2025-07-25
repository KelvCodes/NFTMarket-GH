
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


