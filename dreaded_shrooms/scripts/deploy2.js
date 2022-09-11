const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const BoyDibil = await hre.ethers.getContractFactory("BoyDibil");
    const boyDibil = await BoyDibil.deploy();
    console.log("BoyDibil Contract deployed to:", boyDibil.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
