const { ethers, waffle} = require("hardhat");
const provider = waffle.provider;

async function main() {
    let production = false;
    let testRun = false;

    const [deployer, address1, address2] = await ethers.getSigners();
    console.log("Deployer:", deployer.address);

    // Start: Deployments
    const AMAC2022 = await ethers.getContractFactory("AMAC2022");
    const amac2022 = await AMAC2022.deploy("Albay Multimedia Arts Convention 2022", "AMAC2022", "https://ownly.io/nft/amac2022/");
    console.log("\nAMAC2022 deployed to:", amac2022.address);
    // End: Deployments

    // Start: Contract Initializations

    // End: Contract Initializations

    // Start: Sample Transactions
    if(testRun) {
        await amac2022.airdrop([address1.address, address2.address], [10, 20]);
        console.log("\namac2022.airdrop(10)");

        let totalSupply = await amac2022.totalSupply();
        console.log("\namac2022.totalSupply(): " + totalSupply);
    }
    // End: Sample Transactions
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
