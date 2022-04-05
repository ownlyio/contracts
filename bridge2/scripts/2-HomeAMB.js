const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const HomeAMB = await hre.ethers.getContractFactory("HomeAMB");
    const homeAMB = await HomeAMB.deploy();
    console.log("HomeAMB Contract deployed to:", homeAMB.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("Eternal Storage Proxy Contract deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, homeAMB.address);
    console.log("HomeAMB Implementation added to Proxy");

    // Initialize
    let _validatorContract = ""; // 1.	BridgeValidators

    let HomeAMBProxy = await HomeAMB.attach(eternalStorageProxy.address);
    await HomeAMBProxy.initialize(1, 56, _validatorContract, 2000000, 20000000000, 1, deployer.address);
    console.log("HomeAMB Contract Initialized\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
