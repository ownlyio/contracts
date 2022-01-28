const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Marketplace = await ethers.getContractFactory('MarketplaceEth');

    console.log('Deploying MarketplaceEth...');

    const marketplace_eth = await upgrades.deployProxy(Marketplace, { kind: 'uups' });
    await marketplace_eth.deployed();

    const implHex = await ethers.provider.getStorageAt(
        marketplace_eth.address,
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    const implAddress = ethers.utils.hexStripZeros(implHex);
    console.log('Implementation Address: ', implAddress);

    console.log('MarketplaceEth deployed to: ', marketplace_eth.address);
    console.log('Version: ', await marketplace_eth.version());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });