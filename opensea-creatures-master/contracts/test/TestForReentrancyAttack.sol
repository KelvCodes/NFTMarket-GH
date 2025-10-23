
    // that weil if the CreatureAccessoryFactory.mint() function
    // defends against reentrancy.

    function onERC1155Received(
        address /*_operator*/,
        address /*_from*/,
        uint256 _id,
        uint256 /*_amount*/,
        bytes calldata /*_data*/
    )
        override
        external
        returns(bytes4)
    {
        uint256 balance = IERC1155(msg.sender).balanceOf(address(this), _id);
        if(balance < totalToMint)
        {
            // 1 is the factory lootbox option, not the token id
            CreatureAccessoryFactory(factoryAddress)
                .mint(1, address(this), 1, "");
        }
        return ERC1155_RECEIVED_SIG;
    }

    function supportsInterface(bytes4 interfaceID)
        override
        external
        pure
        returns (bool)
    {
        return interfaceID == INTERFACE_ERC165 ||
            interfaceID == INTERFACE_ERC1155_RECEIVER_FULL;
    }

    // We don't use this but we need it for the interface

    function onERC1155BatchReceived(address /*_operator*/, address /*_from*/, uint256[] memory /*_ids*/, uint256[] memory /*_values*/, bytes memory /*_data*/)
        override public pure returns(bytes4)
    {
        return ERC1155_BATCH_RECEIVED_SIG;
    }
}
