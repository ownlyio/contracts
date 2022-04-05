const hre = require("hardhat");
let argumentPermittableToken = require("bridge2/scripts/arguments/PermittableToken");
let argumentTokenProxy = require("bridge2/scripts/arguments/TokenProxy");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    const PermittableToken = await hre.ethers.getContractFactory("PermittableToken");
    const permittableToken = await PermittableToken.deploy(argumentPermittableToken);
    console.log("Permittable Token Contract deployed to:", permittableToken.address);

    argumentTokenProxy[0] = permittableToken.address;

    const TokenProxy = await hre.ethers.getContractFactory("TokenProxy");
    const tokenProxy = await TokenProxy.deploy(permittableToken.address, argumentTokenProxy);
    console.log("Token Proxy Contract deployed to:", tokenProxy.address);

    // await genesisBlock.mintMultiple("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 100);
    // console.log(await genesisBlock.tokenURI(4));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
