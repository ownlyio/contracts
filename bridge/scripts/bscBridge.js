const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const ForeignAMB = await hre.ethers.getContractFactory("ForeignAMB");
    const foreignAMB = await ForeignAMB.deploy();
    console.log("Foreign AMB Contract deployed to:", foreignAMB.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("Eternal Storage Proxy Contract deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, foreignAMB.address);

    const HomeAMB = await hre.ethers.getContractFactory("ForeignAMB");
    const homeAMB = await HomeAMB.deploy();
    console.log("Home AMB Contract deployed to:", homeAMB.address);

    EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("Eternal Storage Proxy Contract deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, homeAMB.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
