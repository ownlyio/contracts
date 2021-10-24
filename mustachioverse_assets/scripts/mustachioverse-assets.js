const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const MustachioBGContract = await hre.ethers.getContractFactory("MustachioBackgrounds");
  const mustachioBG = await MustachioBGContract.deploy();
  console.log("Mustachio BG Contract deployed to:", mustachioBG.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
