const { ethers } = require('hardhat');

async function main () {
    const BNFT = await ethers.getContractFactory("BNFT");
    const bnft = await BNFT.attach(
        "0xB9f74a918d3bF21be452444e65039e6365DF9B98"
    );

    // for(let i = 2; i <= 10; i++) {
    //     await bnft.createToken("https://ownly.io/nft/titans-of-industry/api/");
    // }

    console.log(await bnft.totalSupply());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });