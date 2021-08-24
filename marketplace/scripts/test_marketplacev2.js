const { ethers, upgrades } = require('hardhat');

async function main () {
    const [deployer] = await ethers.getSigners();

    console.log("Account:", deployer.address);

    const Marketplace = await ethers.getContractFactory('Marketplace');
    const marketplace = await upgrades.deployProxy(Marketplace, { kind: 'uups' });
    await marketplace.deployed();

    console.log('Marketplace deployed to:', marketplace.address);

    const BNFT = await ethers.getContractFactory('BNFT');
    let bnft = await BNFT.deploy();

    console.log('BNFT deployed to:', bnft.address);

    // const Ownly = await ethers.getContractFactory('Ownly');
    // let ownly = await Ownly.deploy();

    // console.log('Ownly deployed to:', ownly.address);

    await bnft.createToken("https://ownly.io/nft/titans-of-industry/api/");
    console.log("Token URI 1:", await bnft.tokenURI(1));

    // await bnft.approve(marketplace.address, 1);
    // await marketplace.createMarketItem(bnft.address, 1, "10000000000000000", "OWN");
    // await marketplace.createMarketSale(1, { value: "0" });
    //
    // console.log(parseInt(transaction.value));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });