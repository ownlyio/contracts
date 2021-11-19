const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const ForeignAMB = await hre.ethers.getContractFactory("ForeignAMB");
    const foreignAMB = await ForeignAMB.deploy();
    console.log("ForeignAMB Contract deployed to:", foreignAMB.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("Eternal Storage Proxy Contract deployed to:", eternalStorageProxy.address);

    eternalStorageProxy.initialize("1", "56", "0x65475e604cF3016a738F8Aac71CEA18b0C2021b4", "2000000", "30000000000");

    await eternalStorageProxy.upgradeTo(1, foreignAMB.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
