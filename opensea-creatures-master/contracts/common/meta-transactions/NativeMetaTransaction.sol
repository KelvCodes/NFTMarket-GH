nonce to ensure uniss
    aram from Address ofuwho signed the tran
        // Verify that the signature match
            verify(userAddress, metaTxgV
            "NativeMetaTransaction: Signer and sig
        // Increment the user's nonce to prevent replay 
        nonces[userAddress]
        emit MetaTransactionExecuted(userAddress, payabsender), fun
        // Forward the call to the contract itself, appendeddress a
        (bool success, bytes memory data) = a
            abi.encodePacked(functionSignature, use)
        );
        require(success, "NativeMetaTransaction: Function call not successful");

        return data;
    }

    /**
     * @notice Generates the EIP-712 hash for the given meta-transaction.
     * @param metaTx The meta-transaction to hash
     * @return Hash of the meta-transaction
     */
    function hashMetaTransaction(MetaTransaction memory metaTx)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                META_TRANSACTION_TYPEHASH,
                metaTx.nonce,
                metaTx.from,
                keccak256(metaTx.functionSignature)
            )
        );
    }

    /**
     * @notice Retrieves the current nonce for a specific user.
     * @param user Address of the user
     * @return nonce The user's current nonce
     */
    function getNonce(address user) public view returns (uint256 nonce) {
        return nonces[user];
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

