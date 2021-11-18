const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const PermittableToken = await hre.ethers.getContractFactory("PermittableToken");
    const permittableToken = await PermittableToken.deploy("Ownly", "wOWN", 18, 4);
    console.log("PermittableToken Contract deployed to:", permittableToken.address);

    let TokenProxy = await hre.ethers.getContractFactory("contracts\\TokenProxy.sol:TokenProxy");
    let tokenProxy = await TokenProxy.deploy(permittableToken.address, "Ownly", "wOWN", 18, 4);
    console.log("TokenProxy Contract deployed to:", tokenProxy.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
