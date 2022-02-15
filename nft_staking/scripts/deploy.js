const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const NFTStaking = await hre.ethers.getContractFactory("NFTStaking");
    const nftStaking = await NFTStaking.deploy();
    console.log("\nNFTStaking deployed to:", nftStaking.address);

    const NFT = await hre.ethers.getContractFactory("NFT");
    const nft = await NFT.deploy();
    console.log("\nNFT deployed to:", nft.address);

    await nftStaking.setCollection(nft.address, true);
    console.log("\nnftStaking.setCollection: " + nft.address + ", true");

    await nftStaking.stake("1000000", "0");
    console.log("\nstake: 1000000, 0");

    await nft.stakeMint(nftStaking.address, 1);
    console.log("\nstakeMint: 1000000, 0");

    let stakingItems = await nftStaking.getStakingItems(deployer.address);
    console.log("\ngetStakingItems:");
    console.log(stakingItems);

    let totalSupply = await nft.totalSupply();
    console.log("\ntotalSupply: " + totalSupply);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
