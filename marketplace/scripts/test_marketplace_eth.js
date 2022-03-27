const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    let MarketplaceEth = await hre.ethers.getContractFactory("MarketplaceEth");
    let marketplaceEth = await MarketplaceEth.attach("0xa1F48610D1A6Da23D7Df80bdDF17108aAb642382");

    let MyERC721Token = await hre.ethers.getContractFactory("MyERC721Token");
    let myERC721Token = await MyERC721Token.attach("0xa3EaC04A75F9f20eDbD00cE55Cb49Ce5310e968e");

    // console.log("\nmyERC721Token.setApprovalForAll:");
    // await myERC721Token.setApprovalForAll("0xa1F48610D1A6Da23D7Df80bdDF17108aAb642382", true);

    console.log("\nmarketplaceEth.createMarketItem:", myERC721Token.address, 0, "100000000000000000");
    await marketplaceEth.createMarketItem(myERC721Token.address, 2, "100000000000000000");

    // console.log("\ncancelMarketItem:");
    // await marketplaceEth.cancelMarketItem(1);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });