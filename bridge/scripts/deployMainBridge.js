const hre = require("hardhat");

async function main() {
    let production = false;
    let testRun = false;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const MainBridge = await hre.ethers.getContractFactory("MainBridge");
    const mainBridge = await MainBridge.deploy();
    console.log("\nMainBridge deployed to:", mainBridge.address);

    let erc20;
    if(testRun) {
        const ERC20 = await hre.ethers.getContractFactory("MyERC20Token");
        erc20 = await ERC20.deploy(deployer.address);
        console.log("\nERC20 deployed to:", erc20.address);
    }
    // End: Deployments

    // Start: Contract Initializations
    let erc20Address = (testRun) ? erc20.address : ((production) ? "0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA" : "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE");
    await mainBridge.setOwnToken(erc20Address);
    console.log("\nmainBridge.setOwnToken: " + erc20Address);
    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {
        let bridgeAmount = "1000000000000000000000000";
        await erc20.approve(mainBridge.address, bridgeAmount);
        console.log("\nerc20.approve: " + bridgeAmount);

        await mainBridge.bridge(bridgeAmount);
        console.log("\nmainBridge.bridge: " + bridgeAmount);

        let balanceOf = await erc20.balanceOf(deployer.address);
        console.log("\nerc20.balanceOf(deployer.address): " + balanceOf);

        balanceOf = await erc20.balanceOf(mainBridge.address);
        console.log("\nerc20.balanceOf(mainBridge.address): " + balanceOf);

        let bridgeItems = await mainBridge.fetchBridgeItems(deployer.address);
        console.log("\nmainBridge.fetchBridgeItems:");
        console.log(bridgeItems);
    }
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
