const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const MustachioContract = await hre.ethers.getContractFactory("Mustachio");
  const mustachio = await MustachioContract.deploy();
  console.log("Mustachio Contract deployed to:", mustachio.address);

  // console.log(await mustachio.functions);
  //
  // await mustachio.mintMustachio({value: "10000000000000000"});
  // console.log(await mustachio.tokenURI(1));
  //
  // await mustachio.setBaseUri("Hello World/");
  // console.log(await mustachio.tokenURI(1));
  //
  // await mustachio.transferFrom(deployer.address, "0x000000000000000000000000000000000000dead", 1);
  //
  // console.log(parseInt(await mustachio.totalSupply()));

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
