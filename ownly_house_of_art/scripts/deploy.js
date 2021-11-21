const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const OwnlyHouseOfArt = await hre.ethers.getContractFactory("OwnlyHouseOfArt");
    const ownlyHouseOfArt = await OwnlyHouseOfArt.deploy();
    console.log("OwnlyHouseOfArt deployed to:", ownlyHouseOfArt.address);

    // await ownlyHouseOfArt.mintMultiple("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 9);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
