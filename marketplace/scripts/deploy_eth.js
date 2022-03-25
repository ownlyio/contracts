const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    // Start: Contract Initializations
    const MarketplaceEth = await hre.ethers.getContractFactory("MarketplaceEth");
    let marketplaceEth = await MarketplaceEth.deploy();
    console.log("\nMarketplaceEth deployed to:", marketplaceEth.address);

    const MyERC721Token = await hre.ethers.getContractFactory("MyERC721Token");
    let erc721 = await MyERC721Token.deploy();
    console.log("\nERC721 deployed to:", erc721.address);
    // End: Contract Initializations

    // Start: Sample Transactions
    await erc721.safeMint(deployer.address);
    console.log("\nerc721.safeMint:", deployer.address);

    let ownerOf = await erc721.ownerOf(0);
    console.log("\nerc721.ownerOf:", ownerOf);

    await erc721.setApprovalForAll(marketplaceEth.address, true);
    console.log("\nerc721.setApprovalForAll:", marketplaceEth.address);

    await marketplaceEth.createMarketItem(erc721.address, 0, '100000000000000000000')
    console.log("\nmarketplaceEth.createMarketItem:", erc721.address, 0, '100000000000000000000');

    let marketItems = await marketplaceEth.fetchMarketItems()
    console.log("\nmarketplaceEth.fetchMarketItems:");
    console.log(marketItems);
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });