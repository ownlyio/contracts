const hre = require("hardhat");

async function main() {
    let isMainnet = false;

    let _sourceChainId = (isMainnet) ? 56 : 97;
    let _destinationChainId = (isMainnet) ? 1 : 4;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    let ForeignAMB = await hre.ethers.getContractFactory("ForeignAMB");
    let foreignAMB = await ForeignAMB.deploy();
    console.log("ForeignAMB Implementation deployed to:", foreignAMB.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("ForeignAMB Proxy deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, foreignAMB.address);
    console.log("ForeignAMB Implementation added to Proxy");

    // Initialize
    let _validatorContract = ""; // 3.	BridgeValidators

    let ForeignAMBProxy = await ForeignAMB.attach(eternalStorageProxy.address);
    await ForeignAMBProxy.initialize(56, 1, _validatorContract, 2000000, 100000000000, 1, deployer.address);
    console.log("ForeignAMB Contract Initialized\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
