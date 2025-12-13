const values = require('./valuesCommon.js');

/**
 * Token index → token ID mapping.
 * Abstracted so the relationship can be changed later if needed.
 */
const tokenIndexToId = (index) => index;

/**
 * ============================================================
 * ACCESSORY NFT SETUP
 * ============================================================
 */

/**
 * Mints all accessory NFTs to the initial owner.
 */
const setupAccessory = async (accessories, owner) => {
  if (!accessories || !owner) {
    throw new Error("Accessories contract or owner address missing");
  }

  console.log("🔧 Setting up accessory NFTs...");

  for (let i = 0; i < values.NUM_ACCESSORIES; i++) {
    const id = tokenIndexToId(i);

    await accessories.create(
      owner,
      id,
      values.MINT_INITIAL_SUPPLY,
      "",        // metadata URI (optional)
      "0x0"      // creator address (unused)
    );

    console.log(`✅ Accessory minted → Token ID: ${id}`);
  }

  console.log("🎉 All accessories minted successfully");
};

/**
 * ============================================================
 * LOOTBOX CONFIGURATION
 * ============================================================
 */

/**
 * Configures lootbox behavior, rarity classes, and probabilities.
 */
const setupAccessoryLootBox = async (lootBox, factory) => {
  if (!lootBox || !factory) {
    throw new Error("LootBox or Factory contract missing");
  }

  console.log("🎁 Configuring accessory lootbox...");

  // Initialize lootbox state
  await lootBox.setState(
    factory.address,
    values.NUM_LOOTBOX_OPTIONS,
    values.NUM_CLASSES,
    1337 // random seed (can be changed later)
  );

  console.log("📦 Lootbox state initialized");

  /**
   * Each rarity class gets exactly one token ID
   * (can be expanded later for multiple IDs per class)
   */
  for (let i = 0; i < values.NUM_CLASSES; i++) {
    const id = tokenIndexToId(i);
    await lootBox.setTokenIdsForClass(i, [id]);

    console.log(`🎯 Class ${i} → Token ID ${id}`);
  }

  /**
   * OPTION SETTINGS
   * Format:
   * setOptionSettings(optionId, maxItems, classProbabilities, guarantees)
   */

  await lootBox.setOptionSettings(
    values.LOOTBOX_OPTION_BASIC,
    3,
    [7300, 2100, 400, 100, 50, 50],
    [0, 0, 0, 0, 0, 0]
  );

  await lootBox.setOptionSettings(
    values.LOOTBOX_OPTION_PREMIUM,
    5,
    [7300, 2100, 400, 100, 50, 50],
    [3, 0, 0, 0, 0, 0]
  );

  await lootBox.setOptionSettings(
    values.LOOTBOX_OPTION_GOLD,
    7,
    [7300, 2100, 400, 100, 50, 50],
    [3, 0, 2, 0, 1, 0]
  );

  console.log("✨ Lootbox options configured");
};

/**
 * ============================================================
 * MASTER SETUP FUNCTION
 * ============================================================
 */

/**
 * Deploys and wires up accessories, factory approvals,
 * and lootbox ownership.
 */
const setupCreatureAccessories = async (
  accessories,
  factory,
  lootBox,
  owner
) => {
  console.log("🚀 Starting full creature accessory setup...");

  // 1. Mint accessories
  await setupAccessory(accessories, owner);

  // 2. Approve factory to manage accessories
  await accessories.setApprovalForAll(factory.address, true, { from: owner });
  console.log("🔐 Factory approved for accessories");

  // 3. Transfer accessory ownership to factory
  await accessories.transferOwnership(factory.address);
  console.log("🏭 Accessories ownership transferred to factory");

  // 4. Configure lootbox
  await setupAccessoryLootBox(lootBox, factory);

  // 5. Transfer lootbox ownership to factory
  await lootBox.transferOwnership(factory.address);
  console.log("🏭 Lootbox ownership transferred to factory");

  console.log("✅ Creature accessory system fully configured");
};

/**
 * ============================================================
 * EXPORTS
 * ============================================================
 */

module.exports = {
  setupAccessory,
  setupAccessoryLootBox,
  setupCreatureAccessories,
};

