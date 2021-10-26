const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const ForeignMultiAMBErc20ToErc677 = await hre.ethers.getContractFactory("ForeignMultiAMBErc20ToErc677");
    const foreignMultiAMBErc20ToErc677 = await ForeignMultiAMBErc20ToErc677.deploy();
    console.log("ForeignMultiAMBErc20ToErc677 Contract deployed to:", foreignMultiAMBErc20ToErc677.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("Eternal Storage Proxy Contract deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, foreignMultiAMBErc20ToErc677.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
