ated a dutch auction sell order! ${dutchAuctionSellOrder.asset.openseaLink}\n`
  );cd5ab";
  const englishAuctionSel
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
