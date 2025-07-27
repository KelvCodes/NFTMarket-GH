
    .send({ from: OWNER_ADDRESS, gas: 100000 })
  console.log('Created. Transaction: ' + result.transactionHash)
}

main()
