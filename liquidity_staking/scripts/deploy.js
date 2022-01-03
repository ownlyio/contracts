const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const StakingRewardsFactory = await hre.ethers.getContractFactory("StakingRewardsFactory");
    const stakingRewardsFactory = await StakingRewardsFactory.deploy();
    console.log("StakingRewardsFactory deployed to:", stakingRewardsFactory.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
