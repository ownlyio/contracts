const hre = require("hardhat");

async function main() {
    let production = false;
    let testRun = false;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const SelfMintingNFT = await hre.ethers.getContractFactory("SelfMintingNFT");
    const selfMintingNFT = await SelfMintingNFT.deploy();
    console.log("\nSelfMintingNFT deployed to:", selfMintingNFT.address);

    let erc20;
    if(testRun) {
        const ERC20 = await hre.ethers.getContractFactory("MyERC20Token");
        erc20 = await ERC20.deploy(deployer.address);
        console.log("\nERC20 deployed to:", erc20.address);
    }
    // End: Deployments

    // Start: Contract Initializations
    let erc20Address = (testRun) ? erc20.address : ((production) ? "0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA" : "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE");
    await selfMintingNFT.setOwnTokenAddress(erc20Address);
    console.log("\nselfMintingNFT.setOwnTokenAddress: " + erc20Address);

    await selfMintingNFT.setAdminAddress(deployer.address);
    console.log("\nselfMintingNFT.setAdminAddress: " + deployer.address);

    await selfMintingNFT.setArtistAddress(deployer.address);
    console.log("\nselfMintingNFT.setArtistAddress: " + deployer.address);
    
    let baseUri = "https://ownly.io/nft/sample/api/";
    await selfMintingNFT.setBaseUri(baseUri);
    console.log("\nselfMintingNFT.setBaseUri: " + baseUri);
    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {
        let mintPrice = await selfMintingNFT.getMintPrice();
        console.log("\nselfMintingNFT.getMintPrice: " + mintPrice);

        await erc20.approve(selfMintingNFT.address, mintPrice);
        console.log("\nerc20.approve: " + mintPrice);

        let tokenId = 1;
        await selfMintingNFT.purchase(tokenId, { value: ethers.utils.parseEther("0.006") });
        console.log("\nselfMintingNFT.purchase: " + tokenId);

        let balanceOf = await erc20.balanceOf(selfMintingNFT.address);
        console.log("\nerc20.balanceOf(selfMintingNFT.address): " + balanceOf);

        balanceOf = await erc20.balanceOf(deployer.address);
        console.log("\nerc20.balanceOf(deployer.address): " + balanceOf);

        await selfMintingNFT.withdraw();
        console.log("\nselfMintingNFT.withdraw:");

        // await selfMintingNFT.withdrawOwnTokens();
        // console.log("\nselfMintingNFT.withdrawOwnTokens:");

        balanceOf = await erc20.balanceOf(deployer.address);
        console.log("\nerc20.balanceOf(deployer.address): " + balanceOf);
    }
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
