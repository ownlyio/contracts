const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const Mustachio = await hre.ethers.getContractFactory("Mustachio");
    const mustachio = await Mustachio.deploy();
    console.log("\nMustachio deployed to:", mustachio.address);

    const NFTStaking = await hre.ethers.getContractFactory("NFTStaking");
    const nftStaking = await NFTStaking.deploy();
    console.log("\nNFTStaking deployed to:", nftStaking.address);

    // const ERC20 = await hre.ethers.getContractFactory("MyERC20Token");
    // const erc20 = await ERC20.deploy(deployer.address);
    // console.log("\nERC20 deployed to:", erc20.address);
    // End: Deployments

    // Start: Contract Initializations
    let counter = 100;
    await mustachio.setLastMintedTokenId(counter);
    console.log("\nmustachio.setLastMintedTokenId: " + counter);

    let stakeRequired = "15000000000000000000000000";
    await mustachio.setStakeRequired(stakeRequired);
    console.log("\nmustachio.setStakeRequired: " + stakeRequired);

    let stakeDuration = 300;
    await mustachio.setStakeDuration(stakeDuration);
    console.log("\nmustachio.setStakeDuration: " + stakeDuration);

    let erc20Address = erc20.address;
    erc20Address = "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE";
    await nftStaking.setStakingTokenAddress(erc20Address);
    console.log("\nnftStaking.setStakingTokenAddress: " + erc20Address);

    await nftStaking.setCollection(mustachio.address, true);
    console.log("\nnftStaking.setCollection: " + mustachio.address + ", true");
    // End: Contract Initializations

    // Start: Sample Transactions
    // let balance = await erc20.balanceOf(deployer.address);
    // console.log("\nerc20.balanceOf: " + balance);
    //
    // let stakedAmount = stakeRequired;
    //
    // await erc20.approve(nftStaking.address, stakedAmount);
    // console.log("\nerc20.approve: " + stakedAmount);
    //
    // await nftStaking.stake(mustachio.address, stakedAmount);
    // console.log("\nnftStaking.stake: " + mustachio.address + ", " + stakedAmount);
    //
    // balance = await erc20.balanceOf(nftStaking.address);
    // console.log("\nNFT staking erc20.balanceOf: " + balance);
    //
    // balance = await erc20.balanceOf(deployer.address);
    // console.log("\nDeployer erc20.balanceOf: " + balance);
    //
    // await mustachio.stakeMint(nftStaking.address, 0);
    // console.log("\nmustachio.stakeMint:");
    //
    // let stakingItems = await nftStaking.getStakingItems(deployer.address);
    // console.log("\nnftStaking.getStakingItems:");
    // console.log(stakingItems);
    //
    // let totalSupply = await mustachio.totalSupply();
    // console.log("\nmustachio.totalSupply: " + totalSupply);
    //
    // balance = await erc20.balanceOf(deployer.address);
    // console.log("\nDeployer erc20.balanceOf: " + balance);
    //
    // let address = await mustachio.ownerOf(101);
    // console.log("\nmustachio.ownerOf: " + address);
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
