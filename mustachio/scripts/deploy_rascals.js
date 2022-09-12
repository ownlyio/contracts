const hre = require("hardhat");

async function main() {
    let production = false;
    let testRun = true;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const MustachioRascals = await hre.ethers.getContractFactory("MustachioRascals");
    const mustachioRascals = await MustachioRascals.deploy("MustachioRascals", "RASCALS", "https://ownly.market/mustachio-rascals", "https://ownly.market/mustachio-rascals-unrevealed", "0xAa313c46175BbD4ED6cf91c710a6f48E4738a9F1");
    console.log("\nMustachioRascals deployed to:", mustachioRascals.address);
    // End: Deployments

    // Start: Contract Initializations
    // let stakeRequired = "15000000000000000000000000";
    // await mustachioRascals.setStakeRequired(stakeRequired);
    // console.log("\nmustachioRascals.setStakeRequired: " + stakeRequired);
    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {
        // let stakingItem2 = await nftRewardStaking.getStakingItem(1);
        // console.log("\nnftRewardStaking.getStakingItem:");
        // console.log(stakingItem2);
    }
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
