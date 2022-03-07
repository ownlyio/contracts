const hre = require("hardhat");

async function main() {
    let testRun = true;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const Mustachio = await hre.ethers.getContractFactory("Mustachio");
    const mustachio = await Mustachio.attach("0xAe02A960b1f94EC806074821b3dfaB4728A6f9c2");
    console.log("\nMustachio deployed to:", mustachio.address);

    const NFTStaking = await hre.ethers.getContractFactory("NFTStaking");
    const nftStaking = await NFTStaking.attach("0x4Ed4EaB801555860FcfAEa722430eb8d3A1f9c4F");
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
