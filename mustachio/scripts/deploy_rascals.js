const hre = require("hardhat");

async function main() {
    let production = false;
    let testRun = true;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const MustachioRascals = await hre.ethers.getContractFactory("MustachioRascals");
    const mustachioRascals = await MustachioRascals.deploy();
    console.log("\nMustachioRascals deployed to:", mustachioRascals.address);

    const NFTRewardStaking = await hre.ethers.getContractFactory("NFTRewardStaking");
    const nftRewardStaking = await upgrades.deployProxy(NFTRewardStaking, { kind: 'uups' });
    await nftRewardStaking.deployed();

    const implHex = await ethers.provider.getStorageAt(
        nftRewardStaking.address,
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    const implAddress = ethers.utils.hexStripZeros(implHex);
    console.log('NFTRewardStaking Implementation Address: ', implAddress);
    console.log('NFTRewardStaking deployed to: ', nftRewardStaking.address);

    let erc20;
    if(testRun) {
        const ERC20 = await hre.ethers.getContractFactory("MyERC20Token");
        erc20 = await ERC20.deploy(deployer.address);
        console.log("\nERC20 deployed to:", erc20.address);
    }
    // End: Deployments

    // Start: Contract Initializations
    let stakeRequired = "15000000000000000000000000";
    await mustachioRascals.setStakeRequired(stakeRequired);
    console.log("\nmustachioRascals.setStakeRequired: " + stakeRequired);

    let stakeDuration = (testRun) ? 0 : ((production) ? 5184000 : 300);
    await mustachioRascals.setStakeDuration(stakeDuration);
    console.log("\nmustachioRascals.setStakeDuration: " + stakeDuration);

    let erc20Address = (testRun) ? erc20.address : ((production) ? "0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA" : "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE");
    await nftRewardStaking.setStakingTokenAddress(erc20Address);
    console.log("\nnftRewardStaking.setStakingTokenAddress: " + erc20Address);

    let collectionMaxStaking = 5000;
    await nftRewardStaking.setCollectionMaxStaking(mustachioRascals.address, collectionMaxStaking);
    console.log("\nnftRewardStaking.setCollectionMaxStaking: " + mustachioRascals.address + ", " + collectionMaxStaking);

    await nftRewardStaking.setFirstStakingItemAsEmpty();
    console.log("\nnftRewardStaking.setFirstStakingItemAsEmpty:");
    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {
        let stakingItem2 = await nftRewardStaking.getStakingItem(1);
        console.log("\nnftRewardStaking.getStakingItem:");
        console.log(stakingItem2);

        let balance = await erc20.balanceOf(deployer.address);
        console.log("\nerc20.balanceOf: " + balance);

        let stakedAmount = stakeRequired;

        await erc20.approve(nftRewardStaking.address, stakedAmount);
        console.log("\nerc20.approve: " + stakedAmount);

        await nftRewardStaking.stake(mustachioRascals.address, stakedAmount);
        console.log("\nnftRewardStaking.stake: " + mustachioRascals.address + ", " + stakedAmount);

        let currentStakingItemId = await nftRewardStaking.getCurrentStakingItemId(deployer.address, mustachioRascals.address);
        console.log("\nnftRewardStaking.getCurrentStakingItemId: " + currentStakingItemId);

        let stakingItem = await nftRewardStaking.getStakingItem(currentStakingItemId);
        console.log("\nnftRewardStaking.getStakingItem:");
        console.log(stakingItem);

        let totalDeposits = await nftRewardStaking.totalDeposits(mustachioRascals.address);
        console.log("\nnftRewardStaking.totalDeposits: " + totalDeposits);

        let remainingRewards = await nftRewardStaking.remainingRewards(mustachioRascals.address);
        console.log("\nnftRewardStaking.remainingRewards: " + remainingRewards);

        balance = await erc20.balanceOf(nftRewardStaking.address);
        console.log("\nNFT staking erc20.balanceOf: " + balance);

        balance = await erc20.balanceOf(deployer.address);
        console.log("\nDeployer erc20.balanceOf: " + balance);

        await mustachioRascals.stakeMint(nftRewardStaking.address, currentStakingItemId);
        console.log("\nmustachioRascals.stakeMint:");

        let totalSupply = await mustachioRascals.totalSupply();
        console.log("\nmustachioRascals.totalSupply: " + totalSupply);

        balance = await erc20.balanceOf(deployer.address);
        console.log("\nDeployer erc20.balanceOf: " + balance);

        let address = await mustachioRascals.ownerOf(1);
        console.log("\nmustachioRascals.ownerOf: " + address);

        let tokenURI = await mustachioRascals.tokenURI(1);
        console.log("\nmustachioRascals.tokenURI: " + tokenURI);

        totalDeposits = await nftRewardStaking.totalDeposits(mustachioRascals.address);
        console.log("\nnftRewardStaking.totalDeposits: " + totalDeposits);

        remainingRewards = await nftRewardStaking.remainingRewards(mustachioRascals.address);
        console.log("\nnftRewardStaking.remainingRewards: " + remainingRewards);

        await erc20.approve(nftRewardStaking.address, stakedAmount);
        console.log("\nerc20.approve: " + stakedAmount);
    }
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
