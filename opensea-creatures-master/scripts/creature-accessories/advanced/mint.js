

  co
    LOOTBOX_CONTRACT_ADDRESS
  )
  const result = await factoryContract.methods
    .unpack(0, OWNER_ADDRESS, 1)
    .send({ from: OWNER_ADDRESS, gas: 100000 })
  console.log('Created. Transaction: ' + result.transactionHash)
}

main()
