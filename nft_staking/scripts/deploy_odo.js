const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const ERC20 = await hre.ethers.getContractFactory("Odo");
    const erc20 = await ERC20.deploy();
    console.log("\nOdo deployed to:", erc20.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
