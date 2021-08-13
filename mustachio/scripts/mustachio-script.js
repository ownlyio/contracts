const hre = require("hardhat");

async function main() {
  const MustachioContract = await hre.ethers.getContractFactory("Mustachio");
  const mustachio = await MustachioContract.deploy();
  console.log("Mustachio Contract deployed to:", mustachio.address);

  // await mustachio.createToken({ value: "10000000000000000" });
  // console.log(await mustachio.tokenURI(1));

  // await hre.run("verify:verify", {
  //     address: mustachio.address,
  //     contract: "contracts/Mustachio.sol:Mustachio",
  // });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
