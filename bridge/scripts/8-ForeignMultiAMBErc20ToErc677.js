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

    // Initialize
    let _bridgeContract = ""; // (4. Foreign AMB))
    let _mediatorContract = ""; // (6. HOMEMULTIAMBERC20TOERC677)
    let _token = ""; // (0. Main Token Contract)

    let ForeignMultiAMBErc20ToErc677Proxy = await ForeignMultiAMBErc20ToErc677.attach(eternalStorageProxy.address);
    await ForeignMultiAMBErc20ToErc677Proxy.initialize(
        _bridgeContract,
        _mediatorContract,
        [
            "15000000000000000000000000",
            "750000000000000000000000",
            "500000000000000000"
        ],
        [
            "30000000000000000000000000",
            "1500000000000000000000000",
            "2000000"
        ],
        deployer.address
    );
    console.log("ForeignMultiAMBErc20ToErc677 Contract Initialized\n");

    await ForeignMultiAMBErc20ToErc677Proxy.setDailyLimit(_token, 75000000000000000000000000);
    console.log("ForeignMultiAMBErc20ToErc677 Contract setDailyLimit\n");

    await ForeignMultiAMBErc20ToErc677Proxy.setExecutionDailyLimit(_token, 75000000000000000000000000);
    console.log("ForeignMultiAMBErc20ToErc677 Contract setExecutionDailyLimit\n");

    await ForeignMultiAMBErc20ToErc677Proxy.setMaxPerTx(_token, 7500000000000000000000000);
    console.log("ForeignMultiAMBErc20ToErc677 Contract setMaxPerTx\n");

    await ForeignMultiAMBErc20ToErc677Proxy.setExecutionMaxPerTx(_token, 7500000000000000000000000);
    console.log("ForeignMultiAMBErc20ToErc677 Contract setExecutionMaxPerTx\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
