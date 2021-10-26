const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const MustachioVerseAssets = await hre.ethers.getContractFactory("MustachioVerseAssets");
    const assets = await MustachioVerseAssets.deploy();
    console.log("Mustachioverse Assets Contract deployed to:", assets.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
