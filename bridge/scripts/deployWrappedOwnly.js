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
    let bridgeValidator = (testRun) ? deployer.address : "0xe5B4f53Eb4c651377e0f98AF67fF506a1c5fC1C9";
    await wrappedOwnly.setBridgeValidator(bridgeValidator);
    console.log("\nwrappedOwnly.setBridgeValidator: " + bridgeValidator);
    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {

    }
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
