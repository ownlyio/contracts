const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("\nTesting contracts with the account:", deployer.address);

    let MarketplaceV2 = await hre.ethers.getContractFactory("MarketplaceV2");
    let marketplaceV2 = await MarketplaceV2.attach("0x457f1e0d886DEA5B8b45F19371E0753562638d4c");

    console.log("\ninitializeV2:");
    await marketplaceV2.setMarketplaceValidator("0xAa313c46175BbD4ED6cf91c710a6f48E4738a9F1");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });