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

    const ERC20 = await hre.ethers.getContractFactory("MyERC20Token");
    const erc20 = await ERC20.deploy(deployer.address);
    console.log("\nERC20 deployed to:", erc20.address);

    let balance = await erc20.balanceOf(deployer.address);
    console.log("\nerc20.balanceOf: " + balance);

    await nftStaking.setStakingTokenAddress(erc20.address);
    console.log("\nnftStaking.setStakingTokenAddress: " + erc20.address);

    await nftStaking.setCollection(nft.address, true);
    console.log("\nnftStaking.setCollection: " + nft.address + ", true");

    let stakedAmount = "1000000000000000000000000";

    await erc20.approve(nftStaking.address, stakedAmount);
    console.log("\nerc20.approve: " + stakedAmount);

    await nftStaking.stake(stakedAmount, "0");
    console.log("\nnftStaking.stake: " + stakedAmount + ", 0");

    balance = await erc20.balanceOf(nftStaking.address);
    console.log("\nNFT staking erc20.balanceOf: " + balance);

    balance = await erc20.balanceOf(deployer.address);
    console.log("\nDeployer erc20.balanceOf: " + balance);

    await nft.stakeMint(nftStaking.address, 0);
    console.log("\nnft.stakeMint:");

    let stakingItems = await nftStaking.getStakingItems(deployer.address);
    console.log("\nnftStaking.getStakingItems:");
    console.log(stakingItems);

    let totalSupply = await nft.totalSupply();
    console.log("\nnft.totalSupply: " + totalSupply);

    balance = await erc20.balanceOf(deployer.address);
    console.log("\nDeployer erc20.balanceOf: " + balance);

    let address = await nft.ownerOf(1);
    console.log("\nnft.ownerOf: " + address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
