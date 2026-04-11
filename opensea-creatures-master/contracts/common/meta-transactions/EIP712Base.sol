
        bytes32 typedMess
        bytes call
    ) interna
        if (signature.length != 65) revert EIPs
            s := calldat
            v := byte
        
     * @param signatu
     * @retu
    function splitory signature) internal pure retur v, bytes32 s) {
        if (signature.length != 65) revert EIP712Base__Invalid
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature,
        
        if (v < 27) v += 27;
    }

    /**
     * @dev Returns the EIP-712 domain hash
     * @return The domain hash
     */
    function getDomainHash() external view returns (bytes32) {
        return _getDomainSeparator();
    }

    /**
     * @dev Returns the EIP-712 domain type hash
     * @return The domain type hash
     */
    function getDomainTypeHash() external pure returns (bytes32) {
        return EIP712_DOMAIN_TYPEHASH;
    }

    /**
     * @dev Checks if domain separator is initialized
     * @return True if initialized
     */
    function isDomainInitialized() external view returns (bool) {
        return _domainInitialized;
    }
}
