roxyRegistryAddress                 // OpenSea Proxy Registry Addr)
    {
        // Constructor body can be left empty as all initialization is handled in ERC1155Tradable
    }

    /**
     * @notice Returns metadata about this contract for OpenSea
     * @dev The returned JSON metadata URL should contain information such as description, image, and external link
     * @return A string containing the URI to the contract-level metadata
     */
    function contractURI() public pure returns (string memory) {
        // Returning a hardcoded URL pointing to OpenSea's contract-level metadata for ERC1155
        return "https://creatures-api.opensea.io/contract/opensea-erc1155";
    }
}

