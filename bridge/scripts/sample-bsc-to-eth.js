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
    let this_address = "0x06F624C9d9448cECf80D0463B75678A49ff88a9a"; // (7. FOREIGNMULTIAMBERC20TOERC677)
    let _bridgeContract = "0x8aA2014CcB4402Fbeb980cB27170C32c65AF8543"; // (4. Foreign AMB))
    let _mediatorContract = "0x20066214fAf84E99C9586602ae35FD43D2254183"; // (6. HOMEMULTIAMBERC20TOERC677)
    let _token = "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE"; // (0. Main Token Contract)

    let ForeignMultiAMBErc20ToErc677Proxy = await ForeignMultiAMBErc20ToErc677.attach(this_address);
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
        ],
        2000000,
        deployer.address
    );
    console.log("ForeignMultiAMBErc20ToErc677 Contract Initialized");

    await ForeignMultiAMBErc20ToErc677Proxy.setDailyLimit(_token, "75000000000000000000000000");
    console.log("ForeignMultiAMBErc20ToErc677 Contract setDailyLimit");

    await ForeignMultiAMBErc20ToErc677Proxy.setExecutionDailyLimit(_token, "75000000000000000000000000");
    console.log("ForeignMultiAMBErc20ToErc677 Contract setExecutionDailyLimit");

    await ForeignMultiAMBErc20ToErc677Proxy.setMaxPerTx(_token, "7500000000000000000000000");
    console.log("ForeignMultiAMBErc20ToErc677 Contract setMaxPerTx");

    await ForeignMultiAMBErc20ToErc677Proxy.setExecutionMaxPerTx(_token, "7500000000000000000000000");
    console.log("ForeignMultiAMBErc20ToErc677 Contract setExecutionMaxPerTx");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
