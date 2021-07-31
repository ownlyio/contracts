const { ethers, upgrades } = require('hardhat');

async function main () {
    const Marketplace = await ethers.getContractFactory("MarketplaceV2");
    const marketplace = await Marketplace.attach(
        "0xcE2609F273a4b232CaC4d796daDc33851D3736c4"
    );

    await marketplace.createMarketItem("0xB9f74a918d3bF21be452444e65039e6365DF9B98", 1, 10000000000000000, {
        value: ethers.utils.parseEther("0")
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });