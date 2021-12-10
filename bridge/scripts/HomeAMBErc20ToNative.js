const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    let HomeAMBErc20ToNative = await hre.ethers.getContractFactory("HomeAMBErc20ToNative");
    let homeAMBErc20ToNative = await HomeAMBErc20ToNative.deploy();
    console.log("HomeAMBErc20ToNative Implementation deployed to:", homeAMBErc20ToNative.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("HomeAMBErc20ToNative Proxy deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, homeAMBErc20ToNative.address);
    console.log("HomeAMBErc20ToNative Implementation added to Proxy");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
