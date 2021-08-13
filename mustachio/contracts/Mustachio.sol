// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mustachio is ERC721, ERC721URIStorage, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    
    uint mintPrice = 0.01 ether;
    string baseUri = "ownly.io/nft/mustachio/api/";
    // address payable admin = payable(0x672b733C5350034Ccbd265AA7636C3eBDDA2223B);
    address payable admin = payable(0x88A14AF453b14070B9B943eea32bf3F534dFa01a);
    
    constructor() ERC721("Mustachio", "MUSTACHIO") {}

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function setBaseUri(string memory _baseUri) internal onlyOwner {
        baseUri = _baseUri;
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function getMintPrice() public view returns (uint) {
        return mintPrice;
    }
    
    function setMintPrice(uint _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }
    
    function createToken() public virtual payable nonReentrant {
        require(msg.value == mintPrice, "Please submit the asking price in order to complete the purchase");
        tokenIds.increment();
        uint tokenId = tokenIds.current();

        admin.transfer(msg.value);

        _mint(msg.sender, tokenId);
    }
}