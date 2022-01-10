const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    let stakingRewardsAddress = "0x73B08F1d787Be5bb0a6572C0444A50A48d55902E";
    let stakingTokenAddress = "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE";
    let amount = "1000000000000000000000000";

    let StakingRewards = await hre.ethers.getContractFactory("StakingRewards");
    let stakingRewards = await StakingRewards.attach(stakingRewardsAddress);

    let StakingToken = await hre.ethers.getContractFactory("OdoKo");
    let stakingToken = await StakingToken.attach(stakingTokenAddress);

    await stakingToken.approve(stakingRewardsAddress, amount);
    console.log("StakingToken: approve(" + amount + ")");

    await stakingRewards.stake(amount);
    console.log("StakingRewards: stake(" + amount + ")");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
