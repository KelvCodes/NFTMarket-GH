ntifier: 
ccak256 hash of the meta-ctyf-712 compl

    brivate constant MA_TRANSACTIONAScak256(
        bytes("MetaTransact56 ddr f
        address payable relayer,//er wh
        bytes functionSign   //
    // Mapping to store nonceeach usrevent replay attacks
    mapp
     * @dev Struct representing a meta-transaction.
     * @param nonce Current user nonce to ensure uniqueness
     * @param from Address of the user who signed the transaction
     * @param functionSignature Encoded function call data
     */
    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    /**
     * @notice Executes a meta-transaction on behalf of a user.
     * @param userAddress The address of the user who signed the meta-transaction
     * @param functionSignature The encoded function to call
     * @param sigR Component of the user's ECDSA signature
     * @param sigS Component of the user's ECDSA signature
     * @param sigV Recovery ID of the user's ECDSA signature
     * @return returnData Data returned from the called function
     */
    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public payable returns (bytes memory returnData) {
        // Create a meta-transaction object using the user's current nonce
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        // Verify that the signature matches the expected signer
        require(
            verify(userAddress, metaTx, sigR, sigS, sigV),
            "NativeMetaTransaction: Signer and signature do not match"
        );

        // Increment the user's nonce to prevent replay attacks
        nonces[userAddress] = nonces[userAddress].add(1);

        emit MetaTransactionExecuted(userAddress, payable(msg.sender), functionSignature);

        // Forward the call to the contract itself, appending the userAddress at the end
        (bool success, bytes memory data) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
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
        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");

        // Recover the signer address from the signature and compare
        return signer == ecrecover(
            toTypedMessageHash(hashMetaTransaction(metaTx)),
            sigV,
            sigR,
            sigS
        );
    }
}

