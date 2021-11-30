const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address, "\n");

    let BridgeValidators = await hre.ethers.getContractFactory("BridgeValidators");
    let bridgeValidators = await BridgeValidators.deploy();
    console.log("BridgeValidators Implementation deployed to:", bridgeValidators.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("BridgeValidators Proxy deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, bridgeValidators.address);
    console.log("BridgeValidators Implementation added to Proxy");

    // Initialize
    let BridgeValidatorsProxy = await BridgeValidators.attach(eternalStorageProxy.address);
    await BridgeValidatorsProxy.initialize(1, ["0xe5B4f53Eb4c651377e0f98AF67fF506a1c5fC1C9"], deployer.address);
    console.log("BridgeValidators Contract Initialized\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
