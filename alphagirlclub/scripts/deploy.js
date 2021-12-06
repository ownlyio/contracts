const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const AlphaGirlClub = await hre.ethers.getContractFactory("AlphaGirlClub");
    const alphaGirlClub = await AlphaGirlClub.deploy();
    console.log("AlphaGirlClub deployed to:", alphaGirlClub.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
