// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract SparkSwapRouterInterface {
    function getAmountsIn(uint amountOut, address[] memory path) public view virtual returns (uint[] memory);
}

contract SelfMintingNFT is ERC721Enumerable, Ownable {
    uint mintPrice = 6000000000000000;
    uint feePercentage = 2;

    string baseUri = "https://ownly.tk/api/launchpad/self-minting-nft/";

    address payable adminAddress;
    address payable artistAddress;
    address ownTokenAddress;

    bool public saleIsActive = true;

    constructor() ERC721("SelfMintingNFT", "SMN") {}

    function setFeePercentage(uint _feePercentage) public onlyOwner virtual {
        feePercentage = _feePercentage;
    }

    function getFeePercentage() public view virtual returns (uint) {
        return feePercentage;
    }

    function setAdminAddress(address payable _adminAddress) public onlyOwner virtual {
        adminAddress = _adminAddress;
    }

    function getAdminAddress() public view virtual returns (address) {
        return adminAddress;
    }

    function setArtistAddress(address payable _artistAddress) public onlyOwner virtual {
        artistAddress = _artistAddress;
    }

    function getArtistAddress() public view virtual returns (address) {
        return artistAddress;
    }

    function reserve(address[] memory accounts, uint[] memory tokenIds) public onlyOwner {
        require(accounts.length == tokenIds.length, "Accounts and Token IDs length must be of same value.");
        for (uint i = 0; i < accounts.length; i++) {
            mintNFT(accounts[i], tokenIds[i]);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function setBaseUri(string memory _baseUri) public onlyOwner {
        baseUri = _baseUri;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function setOwnTokenAddress(address payable _ownTokenAddress) public onlyOwner virtual {
        ownTokenAddress = _ownTokenAddress;
    }

    function getOwnTokenAddress() public view virtual returns (address) {
        return ownTokenAddress;
    }

    function getMintPrice() public view returns (uint) {
        return mintPrice;
    }
    
    function setMintPrice(uint _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function purchase(uint _tokenId) public virtual payable {
        require(saleIsActive, "Sale must be active to mint your Mustachio.");
        require(msg.value == mintPrice, "Please submit the asking price in order to complete the purchase");

        mintNFT(msg.sender, _tokenId);
    }

    function purchaseWithOWN(uint _tokenId) public virtual {
        require(saleIsActive, "Sale must be active to mint your Mustachio.");

//        SparkSwapRouterInterface sparkSwapRouterContract = SparkSwapRouterInterface(0xeB98E6e5D34c94F56708133579abB8a6A2aC2F26);
//
//        address[] memory path = new address[](2);
//        path[0] = ownAddress;
//        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
//
//        uint[] memory ownPrice = sparkSwapRouterContract.getAmountsIn(mintPrice, path);

        IERC20 ownTokenContract = IERC20(ownTokenAddress);

//        uint finalPrice = ownPrice[0];
        uint finalPrice = 1000000000000000000000;
        finalPrice = (finalPrice * 8) / 10;

        ownTokenContract.transferFrom(msg.sender, address(this), finalPrice);

        mintNFT(msg.sender, _tokenId);
    }

    function mintNFT(address _address, uint _tokenId) internal {
        _mint(_address, _tokenId);
    }

    function withdraw() public {
        require(msg.sender == adminAddress || msg.sender == artistAddress, "Withdraw function is only accessible to the admin and artist.");

        uint balance = address(this).balance;

        adminAddress.transfer((balance * feePercentage) / 100);
        artistAddress.transfer((balance * (100 - feePercentage)) / 100);
    }

    function withdrawOwnTokens() public {
        require(msg.sender == adminAddress || msg.sender == artistAddress, "Withdraw function is only accessible to the admin and artist.");

        IERC20 ownTokenContract = IERC20(ownTokenAddress);
        uint balance = ownTokenContract.balanceOf(address(this));

        require(balance > 0, "No OWN tokens can be withdrawn.");

        ownTokenContract.transfer(adminAddress, (balance * feePercentage) / 100);
        ownTokenContract.transfer(artistAddress, (balance * (100 - feePercentage)) / 100);
    }
}