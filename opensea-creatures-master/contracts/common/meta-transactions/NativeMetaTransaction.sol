
    ahe signature match
            v
            "NativeMe
        // Int the us
        (b
                META_T
                keccak256(metaT
     * @notice Retrieves the t nonce for a 
     * @param u
     * @return nonce The
    function getNonce(address user) public vierns (uint256 nonce) {
        return nonce
    }

    /**
     * @notice Verifies that a meta-transaction was signed by the expected signer.
     * @param signer Address expected to have signed the meta-transaction
     * @param metaTx The meta-transaction struct
     * @param sigR R component of the ECDSA signature
     * @param sigS S component of the ECDSA signature
     * @param sigV Recovery ID of the ECDSA signature
     * @return True if the signature is valid, false otherwise
     */
    function verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {
        require(signer != adress(0), "NativeMetaTransaction: INVALID_SIGNER");

        // Recover the signer address from the signature and compare
        return signer == ecrecover(
            toTypedMessageHash(hashMetaTransaction(metaTx)),
            sigV,
            sigR,
            sigS
        );
    }
}

