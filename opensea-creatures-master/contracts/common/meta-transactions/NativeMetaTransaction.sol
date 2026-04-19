
    ahe signature match
         "NativeMe
        // In
        (b
                META_T
                keccak256(metaT
     * @notice
     *
    function get
     * @notice Verifies that a meta-transaction was signe
     * @param signer 
     * @para
     * @param sigS S component of 
     * @return True if the signature is valse ots

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

