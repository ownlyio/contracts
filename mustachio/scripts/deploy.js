const hre = require("hardhat");

async function main() {
    let production = true;
    let testRun = false;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const Mustachio = await hre.ethers.getContractFactory("Mustachio");
    const mustachio = await Mustachio.deploy();
    console.log("\nMustachio deployed to:", mustachio.address);

    const NFTStaking = await hre.ethers.getContractFactory("NFTStaking");
    const nftStaking = await upgrades.deployProxy(NFTStaking, { kind: 'uups' });
    await nftStaking.deployed();

    const implHex = await ethers.provider.getStorageAt(
        nftStaking.address,
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    );
    const implAddress = ethers.utils.hexStripZeros(implHex);
    console.log('NFTStaking Implementation Address: ', implAddress);
    console.log('NFTStaking deployed to: ', nftStaking.address);

    let erc20;
    if(testRun) {
        const ERC20 = await hre.ethers.getContractFactory("MyERC20Token");
        erc20 = await ERC20.deploy(deployer.address);
        console.log("\nERC20 deployed to:", erc20.address);
    }
    // End: Deployments

    // Start: Contract Initializations
    let counter = 100;
    await mustachio.setLastMintedTokenId(counter);
    console.log("\nmustachio.setLastMintedTokenId: " + counter);

    let stakeRequired = "15000000000000000000000000";
    await mustachio.setStakeRequired(stakeRequired);
    console.log("\nmustachio.setStakeRequired: " + stakeRequired);

    let stakeDuration = (testRun) ? 0 : ((production) ? 5184000 : 300);
    await mustachio.setStakeDuration(stakeDuration);
    console.log("\nmustachio.setStakeDuration: " + stakeDuration);

    let erc20Address = (testRun) ? erc20.address : ((production) ? "0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA" : "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE");
    await nftStaking.setStakingTokenAddress(erc20Address);
    console.log("\nnftStaking.setStakingTokenAddress: " + erc20Address);

    let collectionMaxStaking = 200;
    await nftStaking.setCollectionMaxStaking(mustachio.address, collectionMaxStaking);
    console.log("\nnftStaking.setCollectionMaxStaking: " + mustachio.address + ", " + collectionMaxStaking);

    await nftStaking.setFirstStakingItemAsEmpty();
    console.log("\nnftStaking.setFirstStakingItemAsEmpty:");
    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {
        let stakingItem2 = await nftStaking.getStakingItem(1);
        console.log("\nnftStaking.getStakingItem:");
        console.log(stakingItem2);

        let balance = await erc20.balanceOf(deployer.address);
        console.log("\nerc20.balanceOf: " + balance);

        let stakedAmount = stakeRequired;

        await erc20.approve(nftStaking.address, stakedAmount);
        console.log("\nerc20.approve: " + stakedAmount);

        await nftStaking.stake(mustachio.address, stakedAmount);
        console.log("\nnftStaking.stake: " + mustachio.address + ", " + stakedAmount);

        let currentStakingItemId = await nftStaking.getCurrentStakingItemId(deployer.address, mustachio.address);
        console.log("\nnftStaking.getCurrentStakingItemId: " + currentStakingItemId);

        let stakingItem = await nftStaking.getStakingItem(currentStakingItemId);
        console.log("\nnftStaking.getStakingItem:");
        console.log(stakingItem);

        let totalDeposits = await nftStaking.totalDeposits(mustachio.address);
        console.log("\nnftStaking.totalDeposits: " + totalDeposits);

        let remainingRewards = await nftStaking.remainingRewards(mustachio.address);
        console.log("\nnftStaking.remainingRewards: " + remainingRewards);

        balance = await erc20.balanceOf(nftStaking.address);
        console.log("\nNFT staking erc20.balanceOf: " + balance);

        balance = await erc20.balanceOf(deployer.address);
        console.log("\nDeployer erc20.balanceOf: " + balance);

        await mustachio.stakeMint(nftStaking.address, currentStakingItemId);
        console.log("\nmustachio.stakeMint:");

        let totalSupply = await mustachio.totalSupply();
        console.log("\nmustachio.totalSupply: " + totalSupply);

        balance = await erc20.balanceOf(deployer.address);
        console.log("\nDeployer erc20.balanceOf: " + balance);

        let address = await mustachio.ownerOf(101);
        console.log("\nmustachio.ownerOf: " + address);

        let tokenURI = await mustachio.tokenURI(101);
        console.log("\nmustachio.tokenURI: " + tokenURI);

        totalDeposits = await nftStaking.totalDeposits(mustachio.address);
        console.log("\nnftStaking.totalDeposits: " + totalDeposits);

        remainingRewards = await nftStaking.remainingRewards(mustachio.address);
        console.log("\nnftStaking.remainingRewards: " + remainingRewards);

        await erc20.approve(nftStaking.address, stakedAmount);
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
