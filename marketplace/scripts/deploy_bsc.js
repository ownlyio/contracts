const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    // Start: Contract Initializations
    const Marketplace = await ethers.getContractFactory('Marketplace');

    console.log('\nDeploying Marketplace...');

    const marketplace = await upgrades.deployProxy(Marketplace, { kind: 'uups' });
    await marketplace.deployed();

    let implAddress = await upgrades.erc1967.getImplementationAddress(marketplace.address);
    console.log('Marketplace Implementation Address: ', implAddress);

    console.log('Marketplace deployed to: ', marketplace.address);
    console.log('Version: ', await marketplace.version());
    console.log('');

    console.log('Upgrading to MarketplaceV2...');
    const MarketplaceV2 = await ethers.getContractFactory('MarketplaceV2');
    const marketplacev2 = await upgrades.upgradeProxy(marketplace.address, MarketplaceV2);

    implAddress = await upgrades.erc1967.getImplementationAddress(marketplacev2.address);
    console.log('MarketplaceV2 Implementation Address: ', implAddress);

    console.log('MarketplaceV2 deployed to: ', marketplacev2.address);
    console.log('Version: ', await marketplacev2.version());

    const MyERC721Token = await hre.ethers.getContractFactory("MyERC721Token");
    let erc721 = await MyERC721Token.deploy();
    console.log("\nERC721 deployed to:", erc721.address);
    // End: Contract Initializations

    // Start: Sample Transactions
    await erc721.safeMint(deployer.address);
    console.log("\nerc721.safeMint:", deployer.address);

    let ownerOf = await erc721.ownerOf(0);
    console.log("\nerc721.ownerOf:", ownerOf);

    await marketplacev2.createMarketItem(56, erc721.address, 0, '100000000000000000000', "")
    console.log("\nmarketplacev2.createMarketItem:", ownerOf);
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });