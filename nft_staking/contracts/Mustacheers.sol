// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Mustacheers is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    string public PROVENANCE_HASH = "";
    string baseUri = "https://ownly.io/nft/mustacheers/api/";
    uint mintPrice;
    mapping(address => uint) whitelistedAddresses;
    address payable ownlyWallet;

    constructor() ERC721("Mustacheers", "MUSTACHEERS") {}

    function setMintPrice(uint _mintPrice) public onlyOwner virtual {
        mintPrice = _mintPrice;
    }

    function getMintPrice() public view virtual returns (uint) {
        return mintPrice;
    }

    function setOwnlyWallet(address payable _ownlyWallet) public onlyOwner virtual {
        ownlyWallet = _ownlyWallet;
    }

    function getOwnlyWallet() public view virtual returns (address) {
        return ownlyWallet;
    }

    function mintMultiple(address[] memory _addresses) public onlyOwner {
        for(uint i = 0; i < _addresses.length; i++) {
            tokenIds.increment();
            uint tokenId = tokenIds.current();
            _mint(_addresses[i], tokenId);
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

    function addWhitelist(address[] memory _addresses) public onlyOwner {
        for(uint i = 0; i < _addresses.length; i++) {
            whitelistedAddresses[_addresses[i]] = 1;
        }
    }

    function getWhitelist(address _address) public view virtual returns (uint) {
        return whitelistedAddresses[_address];
    }

    function whitelistMint() public {
        require(whitelistedAddresses[msg.sender] == 1, "You are not included in the whitelist.");

        tokenIds.increment();
        uint tokenId = tokenIds.current();
        _mint(msg.sender, tokenId);

        whitelistedAddresses[msg.sender] = 2;
    }

    function purchaseMint() public {
        address ownly_address = 0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE;
        //        address ownly_address = 0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA;

        IERC20 ownlyContract = IERC20(ownly_address);
        uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

        require(mintPrice >= ownlyAllowance, "Please submit the asking price in order to complete the purchase");

        ownlyContract.transferFrom(msg.sender, ownlyWallet, mintPrice);

        tokenIds.increment();
        uint tokenId = tokenIds.current();
        _mint(msg.sender, tokenId);
    }
}