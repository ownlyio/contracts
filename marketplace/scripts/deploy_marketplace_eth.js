const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    const MarketplaceEth = await hre.ethers.getContractFactory("MarketplaceEth");
    let marketplaceEth = await MarketplaceEth.deploy();
    console.log("\nMarketplaceEth deployed to:", marketplaceEth.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });