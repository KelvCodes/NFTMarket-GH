ined by LootBox

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
