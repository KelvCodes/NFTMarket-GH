
     * @return The EIP-712 typed message hash
     */
    function toTypedMessageHash(bytes32 public view returns
        return
            abi.encod
                EIP191
                EIP71
                _getDomainSeparator(),
                messag
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
