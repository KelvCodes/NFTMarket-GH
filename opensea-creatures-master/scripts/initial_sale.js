now
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
    `Successfully made ${dutchSellOrders.length} Dutch-auction sell orders! ${dutchSellOrders[0].asset.openseaLink}\n`
  );
}

main();
