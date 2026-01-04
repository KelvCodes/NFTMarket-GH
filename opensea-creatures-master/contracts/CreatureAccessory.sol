 Accessory structor function
     * @param _proxyRegistryAddress The address of the OpenSea proxy registry to allow gas-less listings
 
     * The constructor calls the parent ERC1155Tradable constructor with:
     * - A descriptive name for the token collection: "OpenSea Creature Accessory"
     * - A symbol for the token collection: "OSCA"
     * - A URI template for metadata: "https://creatures-api.opensea.io/api/accessory/{id}"
     */
    constructor(address _proxyRegistryAddress)
        ERC1155Tradable(
            "OpenSea Creature Accessory",         // Token Collection Name
            "OSCA",                               // Token Symbol
            "https://creatures-api.opensea.io/api/accessory/{id}", // Metadata URI
            _proxyRegistryAddress                 // OpenSea Proxy Registry Address
        )
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

