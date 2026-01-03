// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./IFactoryERC1155.sol";
import "./ERC1155Tradable.sol";

/**
 * @title CreatureAccessoryFactory
 * @author Kelvin
 * @notice Factory contract for minting Creature Accessories & LootBoxes (ERC1155)
 */
contract CreatureAccessoryFactory is
    FactoryERC1155,
    Ownable,
    ReentrancyGuard
{
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error CannotMint();
    error InvalidOption();
    error Unauthorized();

    /*//////////////////////////////////////////////////////////////
                              CONSTANTS
    //////////////////////////////////////////////////////////////*/
    string internal constant BASE_METADATA_URI =
        "https://creatures-api.opensea.io/api/";

    uint256 public constant NUM_ITEM_OPTIONS = 6;
    uint256 public constant NUM_LOOTBOX_OPTIONS = 3;
    uint256 public constant NUM_OPTIONS =
        NUM_ITEM_OPTIONS + NUM_LOOTBOX_OPTIONS;

    uint256 public constant BASIC_LOOTBOX = NUM_ITEM_OPTIONS;
    uint256 public constant PREMIUM_LOOTBOX = NUM_ITEM_OPTIONS + 1;
    uint256 public constant GOLD_LOOTBOX = NUM_ITEM_OPTIONS + 2;

    uint256 internal constant MAX_SUPPLY = type(uint256).max;

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/
    address public immutable proxyRegistryAddress;
    address public immutable nftAddress;
    address public immutable lootBoxAddress;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event Minted(
        address indexed caller,
        address indexed to,
        uint256 indexed optionId,
        uint256 amount
    );

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(
        address _proxyRegistryAddress,
        address _nftAddress,
        address _lootBoxAddress
    ) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
        lootBoxAddress = _lootBoxAddress;
    }

    /*//////////////////////////////////////////////////////////////
                      FACTORY METADATA (OpenSea)
    //////////////////////////////////////////////////////////////*/
    function name() external pure override returns (string memory) {
        return "OpenSea Creature Accessory Pre-Sale";
    }

    function symbol() external pure override returns (string memory) {
        return "OSCAP";
    }

    function supportsFactoryInterface()
        external
        pure
        override
        returns (bool)
    {
        return true;
    }

    function factorySchemaName()
        external
        pure
        override
        returns (string memory)
    {
        return "ERC1155";
    }

    function numOptions() external pure override returns (uint256) {
        return NUM_OPTIONS;
    }

    function uri(uint256 optionId)
        external
        pure
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    BASE_METADATA_URI,
                    "factory/",
                    optionId.toString()
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                          MINTING LOGIC
    //////////////////////////////////////////////////////////////*/
    function canMint(
        uint256 optionId,
        uint256 amount
    ) external view override returns (bool) {
        return _canMint(_msgSender(), optionId, amount);
    }

    function mint(
        uint256 optionId,
        address to,
        uint256 amount,
        bytes calldata data
    ) external override nonReentrant {
        _mint(optionId, to, amount, data);
        emit Minted(msg.sender, to, optionId, amount);
    }

    function _mint(
        uint256 optionId,
        address to,
        uint256 amount,
        bytes memory data
    ) internal {
        if (!_canMint(_msgSender(), optionId, amount)) revert CannotMint();

        // ===================== ACCESSORY ITEMS =====================
        if (optionId < NUM_ITEM_OPTIONS) {
            if (
                !_isOwnerOrProxy(_msgSender()) &&
                _msgSender() != lootBoxAddress
            ) revert Unauthorized();

            ERC1155Tradable(nftAddress).safeTransferFrom(
                owner(),
                to,
                optionId,
                amount,
                data
            );
        }
        // ===================== LOOT BOXES =====================
        else if (optionId < NUM_OPTIONS) {
            if (!_isOwnerOrProxy(_msgSender())) revert Unauthorized();

            uint256 tokenId = optionId - NUM_ITEM_OPTIONS;
            _createOrMint(lootBoxAddress, to, tokenId, amount, data);
        } else {
            revert InvalidOption();
        }
    }

    /*//////////////////////////////////////////////////////////////
                        ERC1155 HELPERS
    //////////////////////////////////////////////////////////////*/
    function _createOrMint(
        address erc1155,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        ERC1155Tradable token = ERC1155Tradable(erc1155);

        if (!token.exists(id)) {
            token.create(to, id, amount, "", data);
        } else {
            token.mint(to, id, amount, data);
        }
    }

    /*//////////////////////////////////////////////////////////////
                          SUPPLY CONTROL
    //////////////////////////////////////////////////////////////*/
    function balanceOf(
        address ownerAddress,
        uint256 optionId
    ) public view override returns (uint256) {
        // ===================== ITEMS =====================
        if (optionId < NUM_ITEM_OPTIONS) {
            if (
                !_isOwnerOrProxy(ownerAddress) &&
                ownerAddress != lootBoxAddress
            ) {
                return 0;
            }

            return
                ERC1155Tradable(nftAddress).balanceOf(
                    owner(),
                    optionId
                );
        }

        // ===================== LOOT BOXES =====================
        if (!_isOwnerOrProxy(ownerAddress)) return 0;

        uint256 tokenId = optionId - NUM_ITEM_OPTIONS;
        uint256 minted = ERC1155Tradable(lootBoxAddress).totalSupply(tokenId);

        return MAX_SUPPLY - minted;
    }

    function _canMint(
        address caller,
        uint256 optionId,
        uint256 amount
    ) internal view returns (bool) {
        return amount > 0 && balanceOf(caller, optionId) >= amount;
    }

    /*//////////////////////////////////////////////////////////////
                         OPENSEA PROXY
    //////////////////////////////////////////////////////////////*/
    function _isOwnerOrProxy(address account)
        internal
        view
        returns (bool)
    {
        ProxyRegistry registry = ProxyRegistry(proxyRegistryAddress);
        return
            account == owner() ||
            address(registry.proxies(owner())) == account;
    }
}
