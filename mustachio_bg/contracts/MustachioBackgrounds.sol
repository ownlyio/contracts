// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MustachioBackgrounds is ERC1155, ReentrancyGuard, Ownable {
    uint mintPrice = 0.01 ether;
    uint edition = 3;

    address payable admin = payable(0x88A14AF453b14070B9B943eea32bf3F534dFa01a);
    // address payable admin = payable(0x672b733C5350034Ccbd265AA7636C3eBDDA2223B);

    string private baseUri = "https://ownly.tk/api/mustachio_bg/";
    string private _name;
    string private _symbol;
    
    mapping(uint => uint) private mintedPerToken;
    
    constructor() ERC1155(baseUri) {
        _name = "Mustachio Backgrounds";
        _symbol = "MUSTACHIO";
    }
    
    // Read Contract
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function tokenURI(uint _tokenId) public view returns (string memory) {
        return string(abi.encodePacked(uri(_tokenId), Strings.toString(_tokenId)));
    }
    
    function getMintPrice() public view returns (uint) {
        return mintPrice;
    }
    
    function getEdition() public view returns (uint) {
        return edition;
    }
    
    function getMintedTokenCount(uint _tokenId) public view returns (uint) {
        return mintedPerToken[_tokenId];
    }
    
    // Write Contract
    function setURI(string memory _newUri) public onlyOwner {
        _setURI(_newUri);
    }
    
    function setEdition(uint _edition) public onlyOwner {
        edition = _edition;
    }
    
    function setMintPrice(uint _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }
    
    function mintBackgroundRewards(address _address, uint _tokenId, uint _quantity) public virtual onlyOwner {
        require(_quantity > 0, "Please submit an amount greater than 0");
        require(_quantity + mintedPerToken[_tokenId] <= edition, "Amount exceeded the total edition per token.");
        
        // admin.transfer(msg.value);
        _mint(_address, _tokenId, _quantity, "0x0");
        mintedPerToken[_tokenId] = mintedPerToken[_tokenId] + _quantity;
    }
    
    function mintBackground(uint _tokenId) public virtual payable nonReentrant {
        require(msg.value == mintPrice, "Please submit the asking price in order to complete the purchase.");
        require(mintedPerToken[_tokenId] < edition, "Maximum mint per token reached.");

        // admin.transfer(msg.value);
        _mint(msg.sender, _tokenId, 1, "0x0");
        mintedPerToken[_tokenId]++;
    }
}
