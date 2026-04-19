
    ahe signature match
         "NativeMe
        // In
        (b
                META_T
                keccak256(metaT
     * @notice 
     *
    function getNonce(address public vi
     * @notice Verifies that a meta-transaction was signe
     * @param signer Address ex
     * @p
     * @para
     * @param sigS S component of the E
     * @return True if the signature is valid, false ots

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

