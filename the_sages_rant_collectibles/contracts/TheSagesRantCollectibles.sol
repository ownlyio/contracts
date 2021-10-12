// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheSagesRantCollectibles is ERC721Enumerable, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    string public PROVENANCE_HASH = "";
    string baseUri = "https://ownly.io/nft/the-sages-rant-collectibles/api/";

    constructor() ERC721("TheSagesRantCollectibles", "THESAGESRANTCOLLECTIBLES") {}

    function mintMultiple(address _address, uint _quantity) public onlyOwner {
        for(uint i = 0; i < _quantity; i++) {
            tokenIds.increment();
            uint tokenId = tokenIds.current();

            _mint(_address, tokenId);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function setBaseUri(string memory _baseUri) public onlyOwner {
        baseUri = _baseUri;
    }

    function setProvenanceHash(string memory _provenanceHash) external onlyOwner {
        PROVENANCE_HASH = _provenanceHash;
    }
}