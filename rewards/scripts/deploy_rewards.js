const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    const OwnlyRewardsContract = await hre.ethers.getContractFactory("OwnlyRewards");
    const ownlyRewards = await OwnlyRewardsContract.deploy();
    console.log("Mustachio Contract deployed to:", ownlyRewards.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
