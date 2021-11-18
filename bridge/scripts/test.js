const hre = require("hardhat");

async function main() {
    const PermittableToken = await ethers.getContractFactory("PermittableToken");
    const permittableToken = await PermittableToken.attach(
        "0x479AF9081EA6144E97204Bad5CCC418F6D9D70a0"
    );

    await permittableToken.mint("0x768532c218f4f4e6E4960ceeA7F5a7A947a1dd61", "1000000000000000000000");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
