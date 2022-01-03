const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    let StakingRewardsFactoryAddress = "";
    let stakingToken = "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE"; // LP token
    let rewardAmount = "1000000000000000000000000"; // Amount in wei (Send to StakingRewardsFactoryAddress before running)

    let StakingRewardsFactory = await hre.ethers.getContractFactory("StakingRewardsFactory");
    let stakingRewardsFactory = await StakingRewardsFactory.attach(StakingRewardsFactoryAddress);

    await stakingRewardsFactory.deploy(stakingToken, rewardAmount);
    console.log("StakingRewardsFactory: deploy()");

    // notifyRewardAmounts
    await stakingRewardsFactory.notifyRewardAmounts();
    console.log("StakingRewardsFactory: notifyRewardAmounts()");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
