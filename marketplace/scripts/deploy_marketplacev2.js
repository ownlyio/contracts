const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    const Marketplace = await ethers.getContractFactory('Marketplace');

    console.log('\nDeploying Marketplace...');

    const marketplace = await upgrades.deployProxy(Marketplace, { kind: 'uups' });
    await marketplace.deployed();

    let implHex = await ethers.provider.getStorageAt(
        marketplace.address,
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    let implAddress = ethers.utils.hexStripZeros(implHex);
    console.log('Marketplace Implementation Address: ', implAddress);

    console.log('Marketplace deployed to: ', marketplace.address);
    console.log('Version: ', await marketplace.version());
    console.log('');

    // MarketplaceV2 Deployment
    console.log('Upgrading to MarketplaceV2...');
    const MarketplaceV2 = await ethers.getContractFactory('MarketplaceV2');
    const marketplacev2 = await upgrades.upgradeProxy(marketplace.address, MarketplaceV2);

    implHex = await ethers.provider.getStorageAt(
        marketplacev2.address,
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    implAddress = ethers.utils.hexStripZeros(implHex);
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