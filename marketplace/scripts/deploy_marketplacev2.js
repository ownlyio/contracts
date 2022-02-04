const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    const Marketplace = await ethers.getContractFactory('Marketplace');

    console.log('\nDeploying Marketplace...');

    const marketplace = await upgrades.deployProxy(Marketplace, { kind: 'uups' });
    await marketplace.deployed();

    let implAddress = await upgrades.erc1967.getImplementationAddress(marketplace.address);
    console.log('Marketplace Implementation Address: ', implAddress);

    console.log('Marketplace deployed to: ', marketplace.address);
    console.log('Version: ', await marketplace.version());
    console.log('');

    // MarketplaceV2 Deployment
    console.log('Upgrading to MarketplaceV2...');
    const MarketplaceV2 = await ethers.getContractFactory('MarketplaceV2');
    const marketplacev2 = await upgrades.upgradeProxy(marketplace.address, MarketplaceV2);

    implAddress = await upgrades.erc1967.getImplementationAddress(marketplacev2.address);
    console.log('MarketplaceV2 Implementation Address: ', implAddress);

    console.log('MarketplaceV2 deployed to: ', marketplacev2.address);
    console.log('Version: ', await marketplacev2.version());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });