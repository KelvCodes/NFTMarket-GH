


      CreatureAccessory,
      proxyRegistryAddress,
      { gas: 5000000 }
    );
    const accessories = await CreatureAccessory.deployed();
    await setupCreatureAccessories.setupAccessory(
      accessories,
      addresses[0]
    );
  }

  if (DEPLOY_ACCESSORIES_SALE) {
    await deployer.deploy(LootBoxRandomness);
    await deployer.link(LootBoxRandomness, CreatureAccessoryLootBox);
    await deployer.deploy(
      CreatureAccessoryLootBox,
      proxyRegistryAddress,
      { gas: 6721975 }
    );
    const lootBox = await CreatureAccessoryLootBox.deployed();
    await deployer.deploy(
      CreatureAccessoryFactory,
      proxyRegistryAddress,
      CreatureAccessory.address,
      CreatureAccessoryLootBox.address,
      { gas: 5000000 }
    );
    const accessories = await CreatureAccessory.deployed();
    const factory = await CreatureAccessoryFactory.deployed();
    await accessories.transferOwnership(
      CreatureAccessoryFactory.address
    );
    await setupCreatureAccessories.setupAccessoryLootBox(lootBox, factory);
    await lootBox.transferOwnership(factory.address);
  }
};
