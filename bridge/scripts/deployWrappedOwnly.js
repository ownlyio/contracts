const hre = require("hardhat");

async function main() {
    let production = false;
    let testRun = false;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const WrappedOwnly = await hre.ethers.getContractFactory("WrappedOwnly");
    const wrappedOwnly = await WrappedOwnly.deploy();
    console.log("\nWrappedOwnly deployed to:", wrappedOwnly.address);
    // End: Deployments

    // Start: Contract Initializations

    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {
        let bridgeValidator = (testRun) ? deployer.address : "0xe5B4f53Eb4c651377e0f98AF67fF506a1c5fC1C9";
        await wrappedOwnly.setBridgeValidator(bridgeValidator);
        console.log("\nwrappedOwnly.setBridgeValidator: " + bridgeValidator);

        let amount = "1000000000000000000000";
        await wrappedOwnly.mint(amount);
        console.log("\nwrappedOwnly.mint: " + amount);

        let totalSupply = await wrappedOwnly.totalSupply();
        console.log("\nwrappedOwnly.totalSupply: " + totalSupply);

        await wrappedOwnly.approve(wrappedOwnly.address, amount);
        console.log("\nwrappedOwnly.approve: " + wrappedOwnly.address + "," + amount);

        await wrappedOwnly.bridge(amount);
        console.log("\nwrappedOwnly.bridge: " + amount);

        totalSupply = await wrappedOwnly.totalSupply();
        console.log("\nwrappedOwnly.totalSupply: " + totalSupply);
    }
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
