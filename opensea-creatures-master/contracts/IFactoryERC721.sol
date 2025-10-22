// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title FactoryERC721
 * @dev A detailed interface for an ERC-721 factory contract.
 *
 * This factory is responsible for creating (minting) ERC721 tokens in a flexible way.
 * Each minting configuration is defined by an `_optionId`, which can represent a specific
 * minting rule, collection, or type of token the factory supports.
 *
 * The factory pattern enables multiple minting behaviors within a single contract —
 * such as minting different NFT types, random drops, limited editions, or tiered rarity systems.
 *
 * NOTE:
 * - This is an interface, not an implementation. 
 * - The actual logic of minting and access control should be implemented in the inheriting contract.
 * - Designed to be compatible with OpenSea's factory and proxy system for seamless integration.
 */
interface FactoryERC721 {

    // ------------------------------------------------------------------------
    // Core Metadata Functions
    // ------------------------------------------------------------------------

    /**
     * @notice Returns the human-readable name of this factory contract.
     * @dev Example: "Creature Factory" or "Genesis NFT Factory"
     * @return The name as a string.
     */
    function name() external view returns (string memory);

    /**
     * @notice Returns the abbreviated symbol for this factory contract.
     * @dev Example: "CRF" or "GNFT"
     * @return The symbol as a string.
     */
    function symbol() external view returns (string memory);

    // ------------------------------------------------------------------------
    // Option Configuration
    // ------------------------------------------------------------------------

    /**
     * @notice Returns the total number of minting options supported by this factory.
     * @dev Each option ID represents a different minting type or configuration.
     *      Example: 
     *        - Option 0 → Mint one standard NFT
     *        - Option 1 → Mint a rare NFT
     *        - Option 2 → Mint a full set or bundle
     * @return The number of available minting options.
     */
    function numOptions() external view returns (uint256);

    // ------------------------------------------------------------------------
    // Minting Logic
    // ------------------------------------------------------------------------

    /**
     * @notice Checks whether a specific minting option can be executed.
     * @dev This function may restrict minting based on supply caps or other business logic.
     *      Example use case:
     *      - Return `false` if max supply for a given option is reached.
     *      - Return `true` if minting is still available.
     * @param _optionId The identifier of the minting option being checked.
     * @return A boolean indicating if this option is available for minting.
     */
    function canMint(uint256 _optionId) external view returns (bool);

    // ------------------------------------------------------------------------
    // Metadata Reference
    // ------------------------------------------------------------------------

    /**
     * @notice Returns metadata describing the minting option.
     * @dev This metadata can follow the ERC721 metadata standard.
     *      It provides descriptive details about what each minting option does,
     *      often used by NFT marketplaces like OpenSea to display visual information.
     *
     * Example:
     * - Option 0 → "Mint a Common Creature"
     * - Option 1 → "Mint a Legendary Creature"
     *
     * @param _optionId The identifier for the minting option.
     * @return A string representing a JSON metadata URI.
     */
    function tokenURI(uint256 _optionId) external view returns (string memory);

    // ------------------------------------------------------------------------
    // Interface Identification
    // ------------------------------------------------------------------------

    /**
     * @notice Identifies this contract as a factory contract.
     * @dev Used to help other contracts or services recognize that this interface
     *      represents a minting factory rather than a standard ERC721 token.
     *      Ideally, this should follow the ERC165 `supportsInterface()` pattern.
     * @return Always returns true if implemented properly.
     */
    function supportsFactoryInterface() external view returns (bool);

    // ------------------------------------------------------------------------
    // Minting Execution
    // ------------------------------------------------------------------------

    /**
     * @notice Executes the minting operation based on a given option.
     * @dev The logic inside the implementing contract determines how many tokens
     *      are minted, what kind they are, and to whom they are sent.
     * 
     * Requirements:
     * - Can only be called by the contract owner or an authorized proxy.
     * - The `_optionId` must be valid (less than `numOptions()`).
     * - The `canMint()` function should return true for this `_optionId`.
     *
     * Example workflow:
     * ```
     *  1. User interacts with marketplace and selects "Mint Rare NFT".
     *  2. Marketplace calls `mint(1, userAddress)` on this factory.
     *  3. Factory creates and transfers the new NFT(s) to `userAddress`.
     * ```
     *
     * @param _optionId The numeric identifier for the chosen minting option.
     * @param _toAddress The recipient address that will own the minted NFT(s).
     */
    function mint(uint256 _optionId, address _toAddress) external;
}

