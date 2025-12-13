
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
};

// Deploy and configure everything

const setupCreatureAccessories = async(accessories, factory, lootBox, owner) => {
  await setupAccessory(accessories, owner);
  await accessories.setApprovalForAll(factory.address, true, { from: owner });
  await accessories.transferOwnership(factory.address);
  await setupAccessoryLootBox(lootBox, factory);
  await lootBox.transferOwnership(factory.address);
};


module.exports = {
  setupAccessory,
  setupAccessoryLootBox,
  setupCreatureAccessories
};
