// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "./Initializable.sol";

/**
 * @title EIP712Base (Improved)
 * @dev Optimized and secure EIP-712 implementation
 */
contract EIP712Base is Initializable {
    // ============================================================
    // CONSTANTS
    // ============================================================

    string public constant VERSION = "1";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes1 private constant EIP191_HEADER = 0x19;
    bytes1 private constant EIP712_VERSION_BYTE = 0x01;

    // secp256k1n / 2
    uint256 private constant HALF_ORDER =
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // ============================================================
    // STORAGE
    // ============================================================

    bytes32 private _domainSeparator;
    uint256 private _initialChainId;
    string private _name;
    bool private _initialized;

    // ============================================================
    // ERRORS
    // ============================================================

    error AlreadyInitialized();
    error NotInitialized();
    error InvalidSignature();
    error InvalidSigner();

    // ============================================================
    // INITIALIZER
    // ============================================================

    function _initializeEIP712(string memory name) internal initializer {
        if (_initialized) revert AlreadyInitialized();

        _name = name;
        _initialChainId = block.chainid;
        _domainSeparator = _buildDomainSeparator();

        _initialized = true;
    }

    // ============================================================
    // DOMAIN LOGIC
    // ============================================================

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(_name)),
                keccak256(bytes(VERSION)),
                block.chainid,
                address(this)
            )
        );
    }

    function _getDomainSeparator() internal view returns (bytes32) {
        if (block.chainid == _initialChainId) {
            return _domainSeparator;
        } else {
            return _buildDomainSeparator(); // fork protection
        }
    }

    function getDomainSeparator() external view returns (bytes32) {
        return _getDomainSeparator();
    }

    // ============================================================
    // HASHING
    // ============================================================

    function toTypedMessageHash(bytes32 structHash)
        public
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                EIP191_HEADER,
                EIP712_VERSION_BYTE,
                _getDomainSeparator(),
                structHash
            )
        );
    }

    // ============================================================
    // SIGNATURE VERIFICATION
    // ============================================================

    function verifySignature(
        address signer,
        bytes32 structHash,
        bytes calldata signature
    ) external view returns (bool) {
        bytes32 digest = toTypedMessageHash(structHash);
        address recovered = _recover(digest, signature);

        if (recovered == address(0)) revert InvalidSignature();
        if (recovered != signer) revert InvalidSigner();

        return true;
    }

    function _recover(bytes32 digest, bytes calldata sig)
        internal
        pure
        returns (address)
    {
        if (sig.length != 65) revert InvalidSignature();

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 32))
            v := byte(0, calldataload(add(sig.offset, 64)))
        }

        if (v < 27) v += 27;

        // Prevent signature malleability
        if (uint256(s) > HALF_ORDER) revert InvalidSignature();

        return ecrecover(digest, v, r, s);
    }

    // ============================================================
    // VIEW HELPERS
    // ============================================================

    function getName() external view returns (string memory) {
        return _name;
    }

    function getChainId() external view returns (uint256) {
        return block.chainid;
    }

    function isInitialized() external view returns (bool) {
        return _initialized;
    }
}

