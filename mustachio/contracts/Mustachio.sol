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
    
    constructor() ERC721("Mustachio", "MUSTACHIO") {}
    
    function _baseURI() internal pure override returns (string memory) {
        return "ownly.io/nft/mustachio/api/";
    }
    
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function getMintPrice() public view returns (uint) {
        return mintPrice;
    }
    
    function setMintPrice(uint _mintPrice) public {
        mintPrice = _mintPrice;
    }
    
    function createToken() public virtual payable nonReentrant {
        require(msg.value == mintPrice, "Please submit the asking price in order to complete the purchase");
        tokenIds.increment();
        uint tokenId = tokenIds.current();
        _mint(msg.sender, tokenId);
    }
}