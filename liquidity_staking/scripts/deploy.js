const hre = require("hardhat");

async function main() {
    // npx hardhat verify CONTRACT_ADDRESS --network NETWORK --constructor-args scripts/arguments/StakingRewardsFactory.js

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    let _rewardsToken = "0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA";
    let _stakingRewardsGenesis = "1641808200"; // January 10, 2022 05:50PM Local Time

    // For Testnet
    // _rewardsToken = "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE";
    // _stakingRewardsGenesis = "1641792600";

    const StakingRewardsFactory = await hre.ethers.getContractFactory("StakingRewardsFactory");
    const stakingRewardsFactory = await StakingRewardsFactory.deploy(_rewardsToken, _stakingRewardsGenesis);
    console.log("StakingRewardsFactory deployed to:", stakingRewardsFactory.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
