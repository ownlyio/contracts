const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const TheSagesRantCollectibles = await hre.ethers.getContractFactory("TheSagesRantCollectibles");
    const theSagesRantCollectibles = await TheSagesRantCollectibles.deploy();
    console.log("The Sages Rant Collectibles deployed to:", theSagesRantCollectibles.address);

    // await theSagesRantCollectibles.mintMultiple("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 9);
    // console.log(await theSagesRantCollectibles.tokenURI(4));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
