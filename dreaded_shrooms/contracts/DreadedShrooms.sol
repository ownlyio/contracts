// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DreadedShrooms is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    string baseUri = "https://ownly.io/nft/dreaded-shrooms/api/";

    constructor() ERC721("DreadedShrooms", "DREADEDSHROOMS") {}

    function mintMultiple(address[] memory accounts) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            tokenIds.increment();
            uint tokenId = tokenIds.current();

            _mint(accounts[i], tokenId);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function setBaseUri(string memory _baseUri) public onlyOwner {
        baseUri = _baseUri;
    }
}