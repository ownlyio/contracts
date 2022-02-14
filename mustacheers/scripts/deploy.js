const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const Mustacheers = await hre.ethers.getContractFactory("Mustacheers");
    const mustacheers = await Mustacheers.deploy();
    console.log("\nMustacheers deployed to:", mustacheers.address);

    await mustacheers.addWhitelist(['0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266']);
    console.log("\naddWhitelist:");

    await mustacheers.whitelistMint();
    console.log("\nwhitelistMint:");

    let totalSupply = await mustacheers.totalSupply();
    console.log("\ntotalSupply: " + totalSupply);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
