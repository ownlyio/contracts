const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    console.log('Upgrading to MarketplaceV3...');
    const MarketplaceV3 = await ethers.getContractFactory('MarketplaceV3');
    const marketplace = await upgrades.upgradeProxy('0x3DA2Af334F3BC6f80Fcad3268441455171A0f53B', MarketplaceV3);

    const implHex = await ethers.provider.getStorageAt(
        marketplace.address,
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    const implAddress = ethers.utils.hexStripZeros(implHex);
    console.log('Implementation Address: ', implAddress);

    // await hre.run("verify:verify", {
    //     address: implAddress
    // });

    console.log('Marketplace deployed to: ', marketplace.address);
    console.log('Version: ', await marketplace.version());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });