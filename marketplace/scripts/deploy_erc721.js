const { ethers } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const MyERC721Token = await ethers.getContractFactory('MyERC721Token');

    console.log('Deploying myERC721Token...');

    const myERC721Token = await MyERC721Token.deploy();
    console.log("\nmyERC721Token.address:", myERC721Token.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });