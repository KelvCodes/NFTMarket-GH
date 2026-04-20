
    ahe signature match
         "
        // I
                META_T
                keccak256(
     * @no
    functio
     * @notice Verifies that a a-trans
     * @
     * @para
     * @
     * @return True if the
    f
        address 
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

