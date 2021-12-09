const hre = require("hardhat");

async function main() {
    let isMainnet = false;

    let _sourceChainId = (isMainnet) ? 56 : 97;
    let _destinationChainId = (isMainnet) ? 1 : 4;

    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    let HomeMultiAMBErc20ToErc677 = await hre.ethers.getContractFactory("contracts\\HomeMultiAMBErc20ToErc677.sol:HomeMultiAMBErc20ToErc677");
    let homeMultiAMBErc20ToErc677 = await HomeMultiAMBErc20ToErc677.deploy();
    console.log("HomeMultiAMBErc20ToErc677 Implementation deployed to:", homeMultiAMBErc20ToErc677.address);

    let EternalStorageProxy = await hre.ethers.getContractFactory("EternalStorageProxy");
    let eternalStorageProxy = await EternalStorageProxy.deploy();
    console.log("HomeMultiAMBErc20ToErc677 Proxy deployed to:", eternalStorageProxy.address);

    await eternalStorageProxy.upgradeTo(1, homeMultiAMBErc20ToErc677.address);
    console.log("HomeMultiAMBErc20ToErc677 Implementation added to Proxy");

    // Initialize
    let _bridgeContract = ""; // (2. HomeAMB)
    let _mediatorContract = ""; // (8. FOREIGNMULTIAMBERC20TOERC677)
    let _tokenImage = ""; // (5. PermittableToken Implementation)
    let _token = ""; // (5. PermittableToken)

    let HomeMultiAMBErc20ToErc677Proxy = await HomeMultiAMBErc20ToErc677.attach(eternalStorageProxy.address);
    await HomeMultiAMBErc20ToErc677Proxy.initialize(
        _bridgeContract,
        _mediatorContract,
        [
            "30000000000000000000000000",
            "1500000000000000000000000",
            "500000000000000000"
        ],
        [
            "15000000000000000000000000",
            "750000000000000000000000",
            "2000000"
        ],
        deployer.address,
        _tokenImage,
        [0x3Fd93C1a6BeAF035D3d0022f449A3669F00165FF],
        ["1000000000000000", "1000000000000000"]
    );
    console.log("HomeMultiAMBErc20ToErc677 Contract Initialized\n");

    await HomeMultiAMBErc20ToErc677Proxy.setFee(
        "0x741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26",
        _token,
        "400000000000000000"
    );
    console.log("HomeMultiAMBErc20ToErc677 Contract Set Fee\n");

    await HomeMultiAMBErc20ToErc677Proxy.setFee(
        "0x03be2b2875cb41e0e77355e802a16769bb8dfcf825061cde185c73bf94f12625",
        _token,
        "1000000000000000"
    );
    console.log("HomeMultiAMBErc20ToErc677 Contract Set Fee\n");

    await HomeMultiAMBErc20ToErc677Proxy.setDailyLimit(
        _token,
        "75000000000000000000000000"
    );
    console.log("HomeMultiAMBErc20ToErc677 Contract Set Daily Limit\n");

    await HomeMultiAMBErc20ToErc677Proxy.setExecutionDailyLimit(
        _token,
        "75000000000000000000000000"
    );
    console.log("HomeMultiAMBErc20ToErc677 Contract Set Execution Daily Limit\n");

    await HomeMultiAMBErc20ToErc677Proxy.setMaxPerTx(
        _token,
        "7500000000000000000000000"
    );
    console.log("HomeMultiAMBErc20ToErc677 Contract Set Max Per Tx\n");

    await HomeMultiAMBErc20ToErc677Proxy.setExecutionMaxPerTx(
        _token,
        "7500000000000000000000000"
    );
    console.log("HomeMultiAMBErc20ToErc677 Contract Set Execution Max Per Tx\n");

    await HomeMultiAMBErc20ToErc677Proxy.setMinPerTx(
        _token,
        "50000000000000000000000"
    );
    console.log("HomeMultiAMBErc20ToErc677 Contract Set Min Per Tx\n");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
