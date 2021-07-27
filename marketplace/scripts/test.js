const { ethers, upgrades } = require('hardhat');

async function main () {
    const Marketplace = await ethers.getContractFactory("MarketplaceV3");
    const marketplace = await Marketplace.attach(
        "0x7bc06c482DEAd17c0e297aFbC32f6e63d3846650"
    );

    await marketplace.setSample(8);
    console.log(parseInt(await marketplace.getSample()));

    await marketplace.setTest(3);
    console.log(parseInt(await marketplace.getTest()));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });