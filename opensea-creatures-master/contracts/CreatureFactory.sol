yed on OpenSea.
     */
    function symbol() override external pure returns (string memory) {
        return "CPF";
    }

    /**
     * @dev Indicates support for factory interface (required by OpenSea).
     */
    function supportsFactoryInterface() override public pure returns (bool) {
        return true;
    }

    /**
     * @dev Returns total number of minting options.
     */
    function numOptions() override public view returns (uint256) {
        return NUM_OPTIONS;
    }

    /**
     * @dev Override to emit Transfer events when ownership changes,
     * keeping OpenSea storefront in sync.
     */
    function transferOwnership(address newOwner) override public onlyOwner {
        address _prevOwner = owner();
        super.transferOwnership(newOwner);
        fireTransferEvents(_prevOwner, newOwner);
    }

    /**
     * @dev Emits Transfer events for all options (required by OpenSea).
     * Called during deployment and ownership changes.
     */
    function fireTransferEvents(address _from, address _to) private {
        for (uint256 i = 0; i < NUM_OPTIONS; i++) {
            emit Transfer(_from, _to, i);
        }
    }

    /**
     * @dev Mints NFTs based on the selected option.
     * Can only be called by the contract owner, their proxy, or the lootbox contract.
     * @param _optionId Which minting option (0,1,2).
     * @param _toAddress Recipient.
     */
    function mint(uint256 _optionId, address _toAddress) override public {
        // Verify caller is owner, proxy, or lootbox contract.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        require(
            address(proxyRegistry.proxies(owner())) == _msgSender() ||
            owner() == _msgSender() ||
            _msgSender() == lootBoxNftAddress,
            "Unauthorized"
        );
        require(canMint(_optionId), "Cannot mint: supply cap reached");

        Creature openSeaCreature = Creature(nftAddress);

        if (_optionId == SINGLE_CREATURE_OPTION) {
            openSeaCreature.mintTo(_toAddress);
        } else if (_optionId == MULTIPLE_CREATURE_OPTION) {
            for (uint256 i = 0; i < NUM_CREATURES_IN_MULTIPLE_CREATURE_OPTION; i++) {
                openSeaCreature.mintTo(_toAddress);
            }
        } else if (_optionId == LOOTBOX_OPTION) {
            CreatureLootBox openSeaCreatureLootBox = CreatureLootBox(lootBoxNftAddress);
            openSeaCreatureLootBox.mintTo(_toAddress);
        }
    }

    /**
     * @dev Checks if minting is possible for the given option,
     * ensuring we don't exceed the total supply cap.
     */
    function canMint(uint256 _optionId) override public view returns (bool) {
        if (_optionId >= NUM_OPTIONS) {
            return false;
        }

        Creature openSeaCreature = Creature(nftAddress);
        uint256 creatureSupply = openSeaCreature.totalSupply();

        uint256 numItemsAllocated;
        if (_optionId == SINGLE_CREATURE_OPTION) {
            numItemsAllocated = 1;
        } else if (_optionId == MULTIPLE_CREATURE_OPTION) {
            numItemsAllocated = NUM_CREATURES_IN_MULTIPLE_CREATURE_OPTION;
        } else if (_optionId == LOOTBOX_OPTION) {
            CreatureLootBox openSeaCreatureLootBox = CreatureLootBox(lootBoxNftAddress);
            numItemsAllocated = openSeaCreatureLootBox.itemsPerLootbox();
        }

        // Ensure total minted + to-be-minted <= supply cap
        return creatureSupply < (CREATURE_SUPPLY - numItemsAllocated);
    }

    /**
     * @dev Returns metadata URL for the given optionId.
     * OpenSea calls this to fetch data for each minting option.
     */
    function tokenURI(uint256 _optionId) override external view returns (string memory) {
        return string(abi.encodePacked(baseURI, Strings.toString(_optionId)));
    }

    /**
     * 🛠 OpenSea compatibility hacks below.
     * These methods mimic ERC721 so OpenSea UI works seamlessly.
     */

    /**
     * @dev Allows OpenSea to "transfer" minting options.
     * Actually triggers mint instead of transfer.
     */
    function transferFrom(
        address,
        address _to,
        uint256 _tokenId
    ) public {
        mint(_tokenId, _to);
    }

    /**
     * @dev Approves owner's proxy on OpenSea to manage factory tokens.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        if (owner() == _owner && _owner == _operator) {
            return true;
        }

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (
            owner() == _owner &&
            address(proxyRegistry.proxies(_owner)) == _operator
        ) {
            return true;
        }

        return false;
    }

    /**
     * @dev Returns factory contract owner as the "owner" of all option tokens.
     */
    function ownerOf(uint256) public view returns (address _owner) {
        return owner();
    }
}

