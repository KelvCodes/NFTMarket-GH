ated a dutch auction sell order! ${dutchAuctionSellOrder.asset.openseaLink}\n`
  );cd5ab";
  const englishAuctionSellOrder = await seaport.createSellOrder({
    asset: {
      tokenId: "3",
      tokenAddress: NFT_CONTRACT_ADDRESS,
      schemaName: WyvernSchemaName.ERC721
    },
    startAmount: 0.03,
    expirationTime: expirationTime,
    waitForHighestBid: true,
    paymentTokenAddress: wethAddress,
    accountAddress: OWNER_ADDRESS,
  });
  console.log(
    `Successfully created an English auction sell order! ${englishAuctionSellOrder.asset.openseaLink}\n`
  );
}

main();
