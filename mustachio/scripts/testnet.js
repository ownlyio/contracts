const hre = require("hardhat");

async function main() {
    let testRun = true;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const Mustachio = await hre.ethers.getContractFactory("Mustachio");
    const mustachio = await Mustachio.attach("0xA628896ec46Ce7C68A0E6eB4aF14fD5EBc834d2d");
    console.log("\nMustachio deployed to:", mustachio.address);

    const NFTStaking = await hre.ethers.getContractFactory("NFTStaking");
    const nftStaking = await NFTStaking.attach("0xC5cBC08ADA3e0d20a537b9386CE9d560aE86058a");
    // End: Deployments

    // Start: Sample Transactions
    let stakeDuration = await mustachio.getStakeDuration();
    console.log("\nmustachio.getStakeDuration: " + stakeDuration);
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
