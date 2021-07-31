const { ethers } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const BNFT = await ethers.getContractFactory('BNFT');

    console.log('Deploying BNFT...');

    const bnft = await BNFT.deploy();

    await hre.run("verify:verify", {
        address: bnft.address
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });