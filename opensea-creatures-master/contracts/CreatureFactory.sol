// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*//////////////////////////////////////////////////////////////
                            IMPORTS
//////////////////////////////////////////////////////////////*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./IFactoryERC721.sol";
import "./Creature.sol";
import "./CreatureLootBox.sol";

/*//////////////////////////////////////////////////////////////
                        FACTORY CONTRACT
//////////////////////////////////////////////////////////////*/

contract CreatureFactory is FactoryERC721, Ownable, ReentrancyGuard, Pausable {
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error Unauthorized();
    error InvalidOption();
    error SupplyExceeded();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// Required by OpenSea to track factory ownership
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /// Emitted when baseURI changes
    event BaseURIUpdated(string newBaseURI);

    /*//////////////////////////////////////////////////////////////
                            IMMUTABLE CONFIG
    //////////////////////////////////////////////////////////////*/

    address public immutable proxyRegistryAddress;
    address public immutable nftAddress;
    address public immutable lootBoxNftAddress;

    /*//////////////////////////////////////////////////////////////
                            FACTORY CONFIG
    //////////////////////////////////////////////////////////////*/

    string public baseURI = "https://creatures-api.opensea.io/api/factory/";

    uint256 public constant CREATURE_SUPPLY = 100;
    uint256 public constant NUM_OPTIONS = 3;

    uint256 public constant SINGLE_CREATURE_OPTION = 0;
    uint256 public constant MULTIPLE_CREATURE_OPTION = 1;
    uint256 public constant LOOTBOX_OPTION = 2;

    uint256 public constant NUM_CREATURES_IN_BUNDLE = 4;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _proxyRegistryAddress, address _nftAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;

        lootBoxNftAddress = address(
            new CreatureLootBox(_proxyRegistryAddress, address(this))
        );

        _fireTransferEvents(address(0), msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                        METADATA (OPENSEA)
    //////////////////////////////////////////////////////////////*/

    function name() external pure override returns (string memory) {
        return "OpenSea Creature Factory";
    }

    function symbol() external pure override returns (string memory) {
        return "OCF";
    }

    function supportsFactoryInterface() public pure override returns (bool) {
        return true;
    }

    function numOptions() public pure override returns (uint256) {
        return NUM_OPTIONS;
    }

    function tokenURI(uint256 optionId) external view override returns (string memory) {
        return string.concat(baseURI, optionId.toString());
    }

    /*//////////////////////////////////////////////////////////////
                        OWNERSHIP MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public override onlyOwner {
        address prevOwner = owner();
        super.transferOwnership(newOwner);
        _fireTransferEvents(prevOwner, newOwner);
    }

    function _fireTransferEvents(address from, address to) internal {
        for (uint256 i = 0; i < NUM_OPTIONS; i++) {
            emit Transfer(from, to, i);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            MINTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint(uint256 optionId, address to)
        public
        override
        nonReentrant
        whenNotPaused
    {
        if (!_isAuthorized()) revert Unauthorized();
        if (!canMint(optionId)) revert SupplyExceeded();

        Creature creature = Creature(nftAddress);

        if (optionId == SINGLE_CREATURE_OPTION) {
            creature.mintTo(to);

        } else if (optionId == MULTIPLE_CREATURE_OPTION) {
            for (uint256 i = 0; i < NUM_CREATURES_IN_BUNDLE; i++) {
                creature.mintTo(to);
            }

        } else if (optionId == LOOTBOX_OPTION) {
            CreatureLootBox(lootBoxNftAddress).mintTo(to);

        } else {
            revert InvalidOption();
        }
    }

    function canMint(uint256 optionId) public view override returns (bool) {
        if (optionId >= NUM_OPTIONS) return false;

        Creature creature = Creature(nftAddress);
        uint256 currentSupply = creature.totalSupply();
        uint256 required;

        if (optionId == SINGLE_CREATURE_OPTION) {
            required = 1;
        } else if (optionId == MULTIPLE_CREATURE_OPTION) {
            required = NUM_CREATURES_IN_BUNDLE;
        } else {
            required = CreatureLootBox(lootBoxNftAddress).itemsPerLootbox();
        }

        return currentSupply + required <= CREATURE_SUPPLY;
    }

    /*//////////////////////////////////////////////////////////////
                    OPENSEA FACTORY HACKS
    //////////////////////////////////////////////////////////////*/

    function transferFrom(
        address,
        address to,
        uint256 tokenId
    ) public {
        mint(tokenId, to);
    }

    function ownerOf(uint256) public view returns (address) {
        return owner();
    }

    function isApprovedForAll(address owner_, address operator)
        public
        view
        returns (bool)
    {
        if (owner() != owner_) return false;

        ProxyRegistry registry = ProxyRegistry(proxyRegistryAddress);
        return
            operator == owner_ ||
            operator == address(registry.proxies(owner_));
    }

    /*//////////////////////////////////////////////////////////////
                        ADMIN CONTROLS
    //////////////////////////////////////////////////////////////*/

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
        emit BaseURIUpdated(newBaseURI);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL HELPERS
    //////////////////////////////////////////////////////////////*/

    function _isAuthorized() internal view returns (bool) {
        ProxyRegistry registry = ProxyRegistry(proxyRegistryAddress);
        return
            msg.sender == owner() ||
            msg.sender == lootBoxNftAddress ||
            msg.sender == address(registry.proxies(owner()));
    }
}

