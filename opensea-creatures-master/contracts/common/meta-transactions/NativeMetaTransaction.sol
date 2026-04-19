
    ahe signature match
         "NativeMe
        // Int the us
        (b
                META_T
                keccak256(metaT
     * @notice Retrieves
     *
    function getNonce(address public vierns (ui
     * @notice Verifies that a meta-transaction was signe signer.
     * @param signer Address expected to have si

     * @param me
     * @param sigR R component of the ECDSAre
     * @param sigS S component of the ECDSA signature
     * @param
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

