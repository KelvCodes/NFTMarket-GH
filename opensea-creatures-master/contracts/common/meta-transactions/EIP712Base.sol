i   function spsignature) internal pure retur v, byt(signature.length != 65) revert EI
            r := mload(add(signature, 32))
            soad(add(signatur
            v := byte(0, 
     * @dev Returns the EIP-712 domain hash
     * @reomain
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
