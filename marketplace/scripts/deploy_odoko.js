const { ethers } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Account:", deployer.address);

    const OdoKo = await ethers.getContractFactory('OdoKo');
    let odo = await OdoKo.deploy();

    console.log('OdoKo deployed to:', odo.address);

    await hre.run("verify:verify", {
        address: odo.address,
        contract: "contracts/bep20/OdoKo.sol:OdoKo"
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });