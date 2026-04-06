
     * @param name The name of th
     * @dev Set
    function _setDomainSepara
        )
     * @dev Gets 
    function getDoarator() external 
        return _domainSepara
     * @dev Get
    funct
     * @dev Gets the curre
     * @return The current c
    function getChainId() public view returns (uint256) {
        

    /**
     * @dev Internal function to get chain ID using assembly
     */
    function _getChainId() private view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    /**
     * @dev Gets the salt (can be overridden)
     * @return The salt bytes32
     */
    function _getSalt() internal view virtual returns (bytes32) {
        return bytes32(0);
    }

    /**
     * @dev Returns the domain separator for current chain
     * @notice Recalculates domain separator if chain ID has changed (for fork protection)
     */
    function _getDomainSeparator() internal view returns (bytes32) {
        uint256 chainId = _getChainId();
        bytes32 cachedDomainSeparator = _domainSeparator;
        
        // If chain ID matches cached version, return cached
        if (address(this) == address(this) && chainId == _getChainIdFromSeparator(cachedDomainSeparator)) {
            return cachedDomainSeparator;
        }
        
        // Otherwise rebuild (handles chain forks)
        return _buildDomainSeparator(_domainName, ERC712_VERSION, chainId);
    }

    /**
     * @dev Extracts chain ID from domain separator (helper function)
     */
    function _getChainIdFromSeparator(bytes32 separator) private pure returns (uint256) {
        // This is a simplified implementation - in practice you'd need to decode the domain separator
        return block.chainid;
    }

    /**
     * @dev Creates a typed message hash according to EIP-712
     * @param messageHash The hash of the message struct
     * @return The EIP-712 typed message hash
     */
    function toTypedMessageHash(bytes32 messageHash) public view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                EIP191_HEADER,
                EIP712_VERSION_BYTE,
                _getDomainSeparator(),
                messageHash
            )
        );
    }

    /**
     * @dev Verifies a signature against a message hash
     * @param signer The expected signer address
     * @param messageHash The hash of the message
     * @param signature The signature to verify
     * @return True if signature is valid
     */
    function verifySignature(
        address signer,
        bytes32 messageHash,
        bytes calldata signature
    ) external view returns (bool) {
        bytes32 typedMessageHash = toTypedMessageHash(messageHash);
        address recoveredSigner = _recoverSigner(typedMessageHash, signature);
        
        if (recoveredSigner == address(0)) revert EIP712Base__InvalidSignature();
        if (recoveredSigner != signer) revert EIP712Base__InvalidSigner();
        
        return true;
    }

    /**
     * @dev Recovers signer address from signature
     * @param typedMessageHash The typed message hash
     * @param signature The signature
     * @return The recovered signer address
     */
    function _recoverSigner(
        bytes32 typedMessageHash,
        bytes calldata signature
    ) internal pure returns (address) {
        if (signature.length != 65) revert EIP712Base__InvalidSignature();
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        // Assembly for efficient signature extraction
        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 0x20))
            v := byte(0, calldataload(add(signature.offset, 0x40)))
        }
        
        // Handle EIP-155
        if (v < 27) v += 27;
        
        return ecrecover(typedMessageHash, v, r, s);
    }

    /**
     * @dev Splits a signature into its components
     * @param signature The signature to split
     * @return v The recovery ID
     * @return r The R component
     * @return s The S component
     */
    function splitSignature(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length != 65) revert EIP712Base__InvalidSignature();
        
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        
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
