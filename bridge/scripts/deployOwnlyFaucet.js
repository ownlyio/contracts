const hre = require("hardhat");

async function main() {
    let production = false;
    let testRun = false;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const OwnlyFaucet = await hre.ethers.getContractFactory("OwnlyFaucet");
    const ownlyFaucet = await OwnlyFaucet.deploy();
    console.log("\nOwnlyFaucet deployed to:", ownlyFaucet.address);

    let erc20;
    if(testRun) {
        const ERC20 = await hre.ethers.getContractFactory("MyERC20Token");
        erc20 = await ERC20.deploy(deployer.address);
        console.log("\nERC20 deployed to:", erc20.address);
    }
    // End: Deployments

    // Start: Contract Initializations

    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {
        let erc20Address = (testRun) ? erc20.address : ((production) ? "0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA" : "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE");
        await ownlyFaucet.setOwnToken(erc20Address);
        console.log("\nownlyFaucet.setOwnToken: " + erc20Address);

        let sender = (testRun) ? deployer.address : "0x768532c218f4f4e6E4960ceeA7F5a7A947a1dd61";
        await ownlyFaucet.setSender(sender);
        console.log("\nownlyFaucet.setSender: " + sender);
    }
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
