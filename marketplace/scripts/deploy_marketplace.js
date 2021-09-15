const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Marketplace = await ethers.getContractFactory('Marketplace');

    console.log('Deploying Marketplace...');

    const marketplace = await upgrades.deployProxy(Marketplace, { kind: 'uups' });
    await marketplace.deployed();

    const implHex = await ethers.provider.getStorageAt(
        marketplace.address,
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    const implAddress = ethers.utils.hexStripZeros(implHex);
    console.log('Implementation Address: ', implAddress);

    console.log('Marketplace deployed to: ', marketplace.address);
    console.log('Version: ', await marketplace.version());

    // await hre.run("verify:verify", {
    //     address: implAddress,
    //     contract: "contracts/Marketplace.sol:Marketplace",
    // });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });