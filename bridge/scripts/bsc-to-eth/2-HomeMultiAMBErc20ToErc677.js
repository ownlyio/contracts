const hre = require("hardhat");

async function main() {
    let isMainnet = false;

    let _sourceChainId = (isMainnet) ? 56 : 97;
    let _destinationChainId = (isMainnet) ? 1 : 4;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    let HomeMultiAMBErc20ToErc677 = await hre.ethers.getContractFactory("HomeMultiAMBErc20ToErc677");
    let homeMultiAMBErc20ToErc677 = await HomeMultiAMBErc20ToErc677.deploy();
    console.log("HomeMultiAMBErc20ToErc677 Implementation deployed to:", homeMultiAMBErc20ToErc677.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("HomeMultiAMBErc20ToErc677 Proxy deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, homeMultiAMBErc20ToErc677.address);
    console.log("ForeignAMB Implementation added to Proxy");

    let HomeMultiAMBErc20ToErc677Proxy = await HomeMultiAMBErc20ToErc677.attach(eternalStorageProxy.address);
    await HomeMultiAMBErc20ToErc677Proxy.initialize(_sourceChainId, _destinationChainId, deployer.address);
    console.log("HomeMultiAMBErc20ToErc677 Contract Initialized\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
