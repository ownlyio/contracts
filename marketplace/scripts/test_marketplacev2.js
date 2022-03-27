const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("\nTesting contracts with the account:", deployer.address);

    let MarketplaceV2 = await hre.ethers.getContractFactory("MarketplaceV2");
    let marketplaceV2 = await MarketplaceV2.attach("0x8258ce60E201064AF359f51a5242242aE7Fcdcb8");

    console.log("\nsetMarketplaceValidator:");
    await marketplaceV2.setMarketplaceValidator("0xAa313c46175BbD4ED6cf91c710a6f48E4738a9F1");

    console.log("\nsetOwnDiscountAmount:");
    await marketplaceV2.setOwnDiscountAmount("20");

    console.log("\ncreateMarketItem:");
    await marketplaceV2.createMarketItem("0x170E719e9aa02C40c2D303Ee8E2D46F49c9f2B80", 0, "100000000000000000", "BNB");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });