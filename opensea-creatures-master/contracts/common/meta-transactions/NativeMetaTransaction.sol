
    ahe signature match
         "NativeMe
        // Int the us
        (b
                META_T
                keccak256(metaT
     * @notice 
     *
    function getNonce(address public vierns (ui
     * @notice Verifies that a meta-transaction was signe
     * @param signer Address ex
     * @param me
     * @param sigR R componen
     * @param sigS S component of the ECDSA signa
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

