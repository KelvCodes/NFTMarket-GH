// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ContextMixin (Improved)
 * @dev Provides correct msg.sender in meta-transactions
 */
abstract contract ContextMixin {
    /**
     * @dev Returns the actual sender of the transaction
     * Handles meta-transactions where the contract calls itself
     */
    function _msgSender() internal view virtual returns (address sender) {
        if (msg.sender == address(this)) {
            // Ensure calldata is long enough (at least 20 bytes for address)
            require(msg.data.length >= 20, "ContextMixin: invalid calldata");

            assembly {
                // Load last 20 bytes of calldata
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            sender = msg.sender;
        }
    }

    /**
     * @dev Returns full calldata
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
