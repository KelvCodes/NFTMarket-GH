

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
