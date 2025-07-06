y _classProbabi
    LootBoxRandomness.setOptionSettings(state, _option, _maxQuantityPerOpen, _classProbabilities, _guarantees);
  }

  ///////
  // MAIN FUNCTIONS
  //////

  function unpack(
    uint256 _optionId,
    address _toAddress,
    uint256 _amount
  ) external {
    // This will underflow if _msgSender() does not own enough tokens.
    _burn(_msgSender(), _optionId, _amount);
    // Mint nfts contained by LootBox
    LootBoxRandomness._mint(state, _optionId, _toAddress, _amount, "", address(this));
  }

  /**
   *  @dev Mint the token/option id.
   */
  function mint(
    address _to,
    uint256 _optionId,
    uint256 _amount,
    bytes memory _data
  ) override public nonReentrant {
    require(_isOwnerOrProxy(_msgSender()), "Lootbox: owner or proxy only");
    require(_optionId < state.numOptions, "Lootbox: Invalid Option");
    // Option ID is used as a token ID here
    _mint(_to, _optionId, _amount, _data);
  }

  /**
   *  @dev track the number of tokens minted.
   */
  function _mint(
    address _to,
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
  ) override internal  {
    tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    super._mint(_to, _id, _quantity, _data);
  }

  function _isOwnerOrProxy(
    address _address
  ) internal view returns (bool) {
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    return owner() == _address || address(proxyRegistry.proxies(owner())) == _address;
  }
}
