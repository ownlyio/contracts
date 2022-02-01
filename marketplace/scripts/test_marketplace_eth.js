const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    let MarketplaceEth = await hre.ethers.getContractFactory("MarketplaceEth");
    let marketplaceEth = await MarketplaceEth.attach("0xB8CA3CEf7275ED0AdaA7A149efE1A06ceb3Db589");

    // console.log("\ncreateMarketItem:");
    // await marketplaceEth.createMarketItem("0x421dC2b62713223491Daf075C23B39EF0E340E94", 1, "100000000000000000", "BNB");

    console.log("\ncancelMarketItem:");
    await marketplaceEth.cancelMarketItem(1);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });