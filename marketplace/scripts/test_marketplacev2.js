const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("\nTesting contracts with the account:", deployer.address);

    let MarketplaceV2 = await hre.ethers.getContractFactory("MarketplaceV2");
    let marketplaceV2 = await MarketplaceV2.attach("0xe6e548d53e360f73ee510b3ce437524d7174a46d");

    console.log("\nsetMarketplaceValidator:");
    await marketplaceV2.setMarketplaceValidator("0xAa313c46175BbD4ED6cf91c710a6f48E4738a9F1");

    console.log("\nsetOwnDiscountAmount:");
    await marketplaceV2.setOwnDiscountAmount("20");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });