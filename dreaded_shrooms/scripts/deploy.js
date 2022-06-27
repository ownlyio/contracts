const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const DreadedShrooms = await hre.ethers.getContractFactory("DreadedShrooms");
    const dreadedShrooms = await DreadedShrooms.deploy();
    console.log("DreadedShrooms Contract deployed to:", dreadedShrooms.address);

    // await genesisBlock.mintMultiple("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 100);
    // console.log(await genesisBlock.tokenURI(4));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
