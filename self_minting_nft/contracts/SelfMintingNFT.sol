// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SelfMintingNFT is ERC721Enumerable, Ownable {
    uint mintPrice = 200000 ether;
    uint fee = 20;

    string baseUri = "https://ownly.tk/api/mustachio-3D/";

    address payable adminAddress;
    address payable artistAddress;
    address ownTokenAddress;

    bool public saleIsActive = true;

    constructor() ERC721("SelfMintingNFT", "SMN") {}

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

        IERC20 ownTokenContract = IERC20(ownTokenAddress);
        uint allowance = ownTokenContract.allowance(msg.sender, address(this));

        require(allowance >= mintPrice, "Please approve the NFT contract with the right minting amount.");

        ownTokenContract.transferFrom(msg.sender, address(this), mintPrice);

        mintNFT(msg.sender, _tokenId);
    }

    function mintNFT(address _address, uint _tokenId) internal {
        _mint(_address, _tokenId);
    }

    function withdraw() public onlyOwner {
        adminAddress.transfer(address(this).balance);
    }

    function withdrawOwnTokens() public onlyOwner {
        require(msg.sender == adminAddress || msg.sender == artistAddress, "Withdraw function is only accessible to the admin and artist.");

        IERC20 ownTokenContract = IERC20(ownTokenAddress);
        uint balance = ownTokenContract.balanceOf(address(this));

        require(balance > 0, "No OWN tokens can be withdrawn.");

        ownTokenContract.transfer(adminAddress, (balance * 2) / 100);
        ownTokenContract.transfer(artistAddress, (balance * 98) / 100);
    }
}