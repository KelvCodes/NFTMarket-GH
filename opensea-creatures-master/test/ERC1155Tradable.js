

  describe('#totalSupply()', () => {
    it('should return correct value for token supply',
       async () => {
         tokenId += 1;
         await instance.create(owner, tokenId, MINT_AMOUNT, "", "0x0", { from: owner });
         const balance = await instance.balanceOf(owner, tokenId);
         assert.ok(balance.eq(MINT_AMOUNT));
         // Use the created getter for the map
         const supplyGetterValue = await instance.tokenSupply(tokenId);
         assert.ok(supplyGetterValue.eq(MINT_AMOUNT));
         // Use the hand-crafted accessor
         const supplyAccessorValue = await instance.totalSupply(tokenId);
         assert.ok(supplyAccessorValue.eq(MINT_AMOUNT));

         // Make explicitly sure everything mateches
         assert.ok(supplyGetterValue.eq(balance));
         assert.ok(supplyAccessorValue.eq(balance));
       });

    it('should return zero for non-existent token',
       async () => {
         const balanceValue = await instance.balanceOf(
           owner,
           NON_EXISTENT_TOKEN_ID
         );
         assert.ok(balanceValue.eq(toBN(0)));
         const supplyAccessorValue = await instance.totalSupply(
           NON_EXISTENT_TOKEN_ID
         );
         assert.ok(supplyAccessorValue.eq(toBN(0)));
       });
  });

  describe('#setCreator()', () => {
    it('should allow the token creator to set creator to another address',
       async () => {
         await instance.setCreator(userA, [INITIAL_TOKEN_ID], {from: owner});
         const tokenCreator = await instance.creators(INITIAL_TOKEN_ID);
         assert.equal(tokenCreator, userA);
       });

    it('should allow the new creator to set creator to another address',
       async () => {
         await instance.setCreator(creator, [INITIAL_TOKEN_ID], {from: userA});
         const tokenCreator = await instance.creators(INITIAL_TOKEN_ID);
         assert.equal(tokenCreator, creator);
       });

    it('should not allow the token creator to set creator to 0x0',
       () => truffleAssert.fails(
         instance.setCreator(
           vals.ADDRESS_ZERO,
           [INITIAL_TOKEN_ID],
           { from: creator }
         ),
         truffleAssert.ErrorType.revert,
         'ERC1155Tradable#setCreator: INVALID_ADDRESS.'
       ));

    it('should not allow a non-token-creator to set creator',
       // Check both a user and the owner of the contract
       async () => {
         await truffleAssert.fails(
           instance.setCreator(userA, [INITIAL_TOKEN_ID], {from: userA}),
           truffleAssert.ErrorType.revert,
           'ERC1155Tradable#creatorOnly: ONLY_CREATOR_ALLOWED'
         );
         await truffleAssert.fails(
           instance.setCreator(owner, [INITIAL_TOKEN_ID], {from: owner}),
           truffleAssert.ErrorType.revert,
           'ERC1155Tradable#creatorOnly: ONLY_CREATOR_ALLOWED'
         );
       });
  });

  describe('#mint()', () => {
    it('should allow creator to mint tokens',
       async () => {
         await instance.mint(
           userA,
           INITIAL_TOKEN_ID,
           MINT_AMOUNT,
           "0x0",
           { from: creator }
         );
         let supply = await instance.totalSupply(INITIAL_TOKEN_ID);
         assert.isOk(supply.eq(MINT_AMOUNT));
       });

    it('should update token totalSupply when minting', async () => {
      let supply = await instance.totalSupply(INITIAL_TOKEN_ID);
      assert.isOk(supply.eq(MINT_AMOUNT));
      await instance.mint(
        userA,
        INITIAL_TOKEN_ID,
        MINT_AMOUNT,
        "0x0",
        { from: creator }
      );
      supply = await instance.totalSupply(INITIAL_TOKEN_ID);
      assert.isOk(supply.eq(MINT_AMOUNT.mul(toBN(2))));
    });

    it('should not overflow token balances',
       async () => {
         const supply = await instance.totalSupply(INITIAL_TOKEN_ID);
         assert.isOk(supply.eq(MINT_AMOUNT.add(MINT_AMOUNT)));
         await truffleAssert.fails(
           instance.mint(
             userB,
             INITIAL_TOKEN_ID,
             OVERFLOW_NUMBER,
             "0x0",
             {from: creator}
           ),
           truffleAssert.ErrorType.revert,
           "revert"
         );
       });
  });

  describe('#batchMint()', () => {
    it('should correctly set totalSupply',
       async () => {
         await instance.batchMint(
           userA,
           [INITIAL_TOKEN_ID],
           [MINT_AMOUNT],
           "0x0",
           { from: creator }
         );
         const supply = await instance.totalSupply(INITIAL_TOKEN_ID);
         assert.isOk(
           supply.eq(MINT_AMOUNT.mul(toBN(3)))
         );
       });

    it('should not overflow token balances',
       () => truffleAssert.fails(
         instance.batchMint(
           userB,
           [INITIAL_TOKEN_ID],
           [OVERFLOW_NUMBER],
           "0x0",
           { from: creator }
         ),
         truffleAssert.ErrorType.revert
       )
      );

    it('should require that caller has permission to mint each token',
       async () => truffleAssert.fails(
         instance.batchMint(
           userA,
           [INITIAL_TOKEN_ID],
           [MINT_AMOUNT],
           "0x0",
           { from: userB }
         ),
         truffleAssert.ErrorType.revert,
         'ERC1155Tradable#batchMint: ONLY_CREATOR_ALLOWED'
       ));
  });

  describe ('#uri()', () => {
    it('should return the uri that supports the substitution method', async () => {
      const uriTokenId = 1;
      const uri = await instance.uri(uriTokenId);
      assert.equal(uri, `${vals.URI_BASE}`);
    });

    it('should not return the uri for a non-existent token', async () =>
       truffleAssert.fails(
         instance.uri(NON_EXISTENT_TOKEN_ID),
         truffleAssert.ErrorType.revert,
         'NONEXISTENT_TOKEN'
       )
      );
  });

  describe ('#setURI()', () => {
    newUri = "https://newuri.com/{id}"
    it('should allow the owner to set the url', async () => {
       truffleAssert.passes(
         await instance.setURI(newUri, { from: owner })
       );
       const uriTokenId = 1;
       const uri = await instance.uri(uriTokenId);
       assert.equal(uri, newUri);
    });

    it('should not allow non-owner to set the url', async () =>
       truffleAssert.fails(
         instance.setURI(newUri, { from: userA }),
         truffleAssert.ErrorType.revert,
         'Ownable: caller is not the owner'
       ));
  });

  describe ('#setCustomURI()', () => {
    customUri = "https://customuri.com/metadata"
    it('should allow the creator to set the custom uri of a token', async () => {
      tokenId += 1;
      await instance.create(owner, tokenId, 0, "", "0x0", { from: owner });
      truffleAssert.passes(
        await instance.setCustomURI(tokenId, customUri, { from: owner })
      );
      const uri = await instance.uri(tokenId);
      assert.equal(uri, customUri);
    });

    it('should not allow non-creator to set the custom url of a token', async () => {
      tokenId += 1;
      await instance.create(owner, tokenId, 0, "", "0x0", { from: owner });
      truffleAssert.fails(
        instance.setCustomURI(tokenId, customUri, { from: userB })
      );
      });
  });


  describe('#isApprovedForAll()', () => {
    it('should approve proxy address as _operator', async () => {
      assert.isOk(
        await instance.isApprovedForAll(owner, proxyForOwner)
      );
    });

    it('should not approve non-proxy address as _operator', async () => {
      assert.isNotOk(
        await instance.isApprovedForAll(owner, userB)
      );
    });

    it('should reject proxy as _operator for non-owner _owner', async () => {
      assert.isNotOk(
        await instance.isApprovedForAll(userA, proxyForOwner)
      );
    });

    it('should accept approved _operator for _owner', async () => {
      await instance.setApprovalForAll(userB, true, { from: userA });
      assert.isOk(await instance.isApprovedForAll(userA, userB));
      // Reset it here
      await instance.setApprovalForAll(userB, false, { from: userA });
    });

    it('should not accept non-approved _operator for _owner', async () => {
      await instance.setApprovalForAll(userB, false, { from: userA });
      assert.isNotOk(await instance.isApprovedForAll(userA, userB));
    });
  });

  describe("#executeMetaTransaction()", function () {
    it("should allow calling setApprovalForAll with a meta transaction", async function () {
      const wallet = new MockProvider().createEmptyWallet();
      const user = await wallet.getAddress()

      let name = await instance.name();
      let nonce = await instance.getNonce(user);
      let version = await instance.ERC712_VERSION();
      let chainId = await instance.getChainId();
      let domainData = {
        name: name,
        version: version,
        verifyingContract: instance.address,
        salt: '0x' + web3.utils.toHex(chainId).substring(2).padStart(64, '0'),
      };
      const functionSignature = await web3ERC1155.methods.setApprovalForAll(approvedContract.address, true).encodeABI()
      let { r, s, v } = await signMetaTransaction(
        wallet,
        nonce,
        domainData,
        functionSignature
      );

      assert.equal(await instance.isApprovedForAll(user, approvedContract.address), false);
      truffleAssert.eventEmitted(
        await instance.executeMetaTransaction(
          user,
          functionSignature,
          r,
          s,
          v
        ),
        'ApprovalForAll',
        {
          account: user,
          operator: approvedContract.address,
          approved: true
        }
      );
      assert.equal(await instance.isApprovedForAll(user, approvedContract.address), true);
    });
  });
});
