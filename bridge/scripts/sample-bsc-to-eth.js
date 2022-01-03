const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const Ownly = await hre.ethers.getContractFactory("OdoKo");

    let ownly_address = "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE"; // (0. Ownly)
    let ForeignMultiAMBErc20ToErc677Address = "0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE"; // (7. ForeignMultiAMBErc20ToErc677)

    let ownly = await Ownly.attach(ownly_address);
    await ownly.approve(ForeignMultiAMBErc20ToErc677Address, "100000000000000000000000");

    const ForeignMultiAMBErc20ToErc677 = await hre.ethers.getContractFactory("ForeignMultiAMBErc20ToErc677");

    let foreignMultiAMBErc20ToErc677 = await ForeignMultiAMBErc20ToErc677.attach(ForeignMultiAMBErc20ToErc677Address);
    await ownly.relayTokens(ownly_address, "100000000000000000000000");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
