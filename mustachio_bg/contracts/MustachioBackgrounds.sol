// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MustachioBackgrounds is ERC1155, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter tokenIds;
    
    uint mintPrice = 0.01 ether;
    uint edition = 3;
    string private baseUri = "https://ownly.tk/api/mustachio_bg/";
    string private _name;
    string private _symbol;
    
    constructor() ERC1155(baseUri) {
        _name = "Mustachio Backgrounds";
        _symbol = "MUSTACHIO";
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function _baseURI() internal view returns (string memory) {
        return baseUri;
    }
    
    function getMintPrice() public view returns (uint) {
        return mintPrice;
    }
    
    function getLastMintedTokenId() public view returns (uint) {
        return tokenIds.current();
    }

    function setURI(string memory _newUri) public onlyOwner {
        _setURI(_newUri);
    }
    
    function setEdition(uint _edition) public onlyOwner {
        edition = _edition;
    }
    
    function setMintPrice(uint _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }
}
