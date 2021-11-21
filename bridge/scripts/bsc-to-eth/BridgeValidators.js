const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    let BridgeValidators = await hre.ethers.getContractFactory("BridgeValidators");
    let bridgeValidators = await BridgeValidators.deploy();
    console.log("BridgeValidators Contract deployed to:", bridgeValidators.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("Eternal Storage Proxy Contract deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, bridgeValidators.address);
    console.log("Implementation added to Proxy");

    BridgeValidators = await ethers.getContractFactory("BridgeValidators");
    eternalStorageProxy = await BridgeValidators.attach(
        eternalStorageProxy.address
    );

    await eternalStorageProxy.initialize(1, ["0xe5B4f53Eb4c651377e0f98AF67fF506a1c5fC1C9"], deployer.address);
    console.log("Initialized");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
