const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const MustachioAseetsContract = await hre.ethers.getContractFactory("MustachioVerseAssets");
  const mustachioAsset = await MustachioAseetsContract.deploy();
  console.log("Mustachioverse Aseets Contract deployed to:", mustachioAsset.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
