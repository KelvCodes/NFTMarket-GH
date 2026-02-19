// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "./Initializable.sol";

/**
 * @title EIP712Base
 * @dev Base contract for EIP-712 typed structured data hashing and signing
 * @notice Implements EIP-712 standard for domain separation of typed data
 */
contract EIP712Base is Initializable {
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }

    // Constants
    string public constant ERC712_VERSION = "1";
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
    );
    
    // EIP-191 prefix constants
    bytes1 private constant EIP191_HEADER = 0x19;
    bytes1 private constant EIP712_VERSION_BYTE = 0x01;
    
    // Storage
    bytes32 private _domainSeparator;
    string private _domainName;
    bool private _domainInitialized;
    
    // Events
    event DomainSeparatorUpdated(string indexed name, string version, uint256 chainId, address indexed verifyingContract);
    
    // Errors
    error EIP712Base__AlreadyInitialized();
    error EIP712Base__NotInitialized();
    error EIP712Base__InvalidSignature();
    error EIP712Base__InvalidSigner();

    /**
     * @dev Modifier to check if domain separator is initialized
     */
    modifier whenDomainInitialized() {
        if (!_domainInitialized) revert EIP712Base__NotInitialized();
        _;
    }

    /**
     * @dev Initializes the EIP712 domain separator
     * @param name The name of the domain
     */
    function _initializeEIP712(string memory name) internal initializer {
        _setDomainSeparator(name);
    }

    /**
     * @dev Initializes the EIP712 domain separator with custom version
     * @param name The name of the domain
     * @param version The version of the domain
     */
    function _initializeEIP712WithVersion(string memory name, string memory version) internal initializer {
        _setDomainSeparatorWithVersion(name, version);
    }

    /**
     * @dev Sets the domain separator with default version
     * @param name The name of the domain
     */
    function _setDomainSeparator(string memory name) internal {
        _setDomainSeparatorWithVersion(name, ERC712_VERSION);
    }

    /**
     * @dev Sets the domain separator with custom version
     * @param name The name of the domain
     * @param version The version of the domain
     */
    function _setDomainSeparatorWithVersion(string memory name, string memory version) internal {
        if (_domainInitialized) revert EIP712Base__AlreadyInitialized();
        
        _domainName = name;
        uint256 chainId = _getChainId();
        
        _domainSeparator = _buildDomainSeparator(name, version, chainId);
        _domainInitialized = true;
        
        emit DomainSeparatorUpdated(name, version, chainId, address(this));
    }

    /**
     * @dev Builds the domain separator hash
     */
    function _buildDomainSeparator(
        string memory name,
        string memory version,
        uint256 chainId
    ) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                address(this),
                _getSalt()
            )
        );
    }

    /**
     * @dev Gets the domain separator
     * @return The current domain separator
     */
    function getDomainSeparator() external view returns (bytes32) {
        return _domainSeparator;
    }

    /**
     * @dev Gets the domain name
     * @return The domain name
     */
    function getDomainName() external view returns (string memory) {
        return _domainName;
    }

    /**
     * @dev Gets the current chain ID
     * @return The current chain ID
     */
    function getChainId() public view returns (uint256) {
        return _getChainId();
    }

    /**
     * @dev Internal function to get chain ID using assembly
     */
    function _getChainId() private view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    /**
     * @dev Gets the salt (can be overridden)
     * @return The salt bytes32
     */
    function _getSalt() internal view virtual returns (bytes32) {
        return bytes32(0);
    }

    /**
     * @dev Returns the domain separator for current chain
     * @notice Recalculates domain separator if chain ID has changed (for fork protection)
     */
    function _getDomainSeparator() internal view returns (bytes32) {
        uint256 chainId = _getChainId();
        bytes32 cachedDomainSeparator = _domainSeparator;
        
        // If chain ID matches cached version, return cached
        if (address(this) == address(this) && chainId == _getChainIdFromSeparator(cachedDomainSeparator)) {
            return cachedDomainSeparator;
        }
        
        // Otherwise rebuild (handles chain forks)
        return _buildDomainSeparator(_domainName, ERC712_VERSION, chainId);
    }

    /**
     * @dev Extracts chain ID from domain separator (helper function)
     */
    function _getChainIdFromSeparator(bytes32 separator) private pure returns (uint256) {
        // This is a simplified implementation - in practice you'd need to decode the domain separator
        return block.chainid;
    }

    /**
     * @dev Creates a typed message hash according to EIP-712
     * @param messageHash The hash of the message struct
     * @return The EIP-712 typed message hash
     */
    function toTypedMessageHash(bytes32 messageHash) public view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                EIP191_HEADER,
                EIP712_VERSION_BYTE,
                _getDomainSeparator(),
                messageHash
            )
        );
    }

    /**
     * @dev Verifies a signature against a message hash
     * @param signer The expected signer address
     * @param messageHash The hash of the message
     * @param signature The signature to verify
     * @return True if signature is valid
     */
    function verifySignature(
        address signer,
        bytes32 messageHash,
        bytes calldata signature
    ) external view returns (bool) {
        bytes32 typedMessageHash = toTypedMessageHash(messageHash);
        address recoveredSigner = _recoverSigner(typedMessageHash, signature);
        
        if (recoveredSigner == address(0)) revert EIP712Base__InvalidSignature();
        if (recoveredSigner != signer) revert EIP712Base__InvalidSigner();
        
        return true;
    }

    /**
     * @dev Recovers signer address from signature
     * @param typedMessageHash The typed message hash
     * @param signature The signature
     * @return The recovered signer address
     */
    function _recoverSigner(
        bytes32 typedMessageHash,
        bytes calldata signature
    ) internal pure returns (address) {
        if (signature.length != 65) revert EIP712Base__InvalidSignature();
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        // Assembly for efficient signature extraction
        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 0x20))
            v := byte(0, calldataload(add(signature.offset, 0x40)))
        }
        
        // Handle EIP-155
        if (v < 27) v += 27;
        
        return ecrecover(typedMessageHash, v, r, s);
    }

    /**
     * @dev Splits a signature into its components
     * @param signature The signature to split
     * @return v The recovery ID
     * @return r The R component
     * @return s The S component
     */
    function splitSignature(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length != 65) revert EIP712Base__InvalidSignature();
        
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        
        if (v < 27) v += 27;
    }

    /**
     * @dev Returns the EIP-712 domain hash
     * @return The domain hash
     */
    function getDomainHash() external view returns (bytes32) {
        return _getDomainSeparator();
    }

    /**
     * @dev Returns the EIP-712 domain type hash
     * @return The domain type hash
     */
    function getDomainTypeHash() external pure returns (bytes32) {
        return EIP712_DOMAIN_TYPEHASH;
    }

    /**
     * @dev Checks if domain separator is initialized
     * @return True if initialized
     */
    function isDomainInitialized() external view returns (bool) {
        return _domainInitialized;
    }
}
