// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MustachioRascals is ERC721A, Ownable {
    using Strings for uint256;

    string public baseURI;
    string public notRevealedUri;
    uint256 public cost1 = 0.025 ether;
    uint256 public cost2 = 0.018 ether;
    uint256 public cost3 = 0.014 ether;
    uint256 public cost4 = 0.009 ether;
    uint256 public whitelistedPricePercentage = 75;
    uint256 public maxSupply = 10000;
    bool public paused = false;
    bool public revealed = false;
    bool public onlyWhitelisted = true;

    mapping(address => uint) freeMints;
    mapping(address => bool) whitelistedAddresses;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721A(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function mint(uint256 _mintAmount) public payable {
        require(!paused, "the contract is paused");
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

        if(msg.sender != owner()) {
            bool _isWhitelisted = isWhitelisted(msg.sender);

            if(onlyWhitelisted == true) {
                require(isWhitelisted(msg.sender), "user is not whitelisted");
            }

            uint256 cost = 0;

            if(_mintAmount <= 2) {
                cost = (_isWhitelisted) ? (cost1 * whitelistedPricePercentage) / 100 : cost1;
            } else if(_mintAmount <= 4) {
                cost = (_isWhitelisted) ? (cost2 * whitelistedPricePercentage) / 100 : cost2;
            } else if(_mintAmount <= 9) {
                cost = (_isWhitelisted) ? (cost3 * whitelistedPricePercentage) / 100 : cost3;
            } else {
                cost = (_isWhitelisted) ? (cost4 * whitelistedPricePercentage) / 100 : cost4;
            }

            require(msg.value >= cost * _mintAmount, "insufficient funds");
        }

        _mint(msg.sender, _mintAmount);
    }

    function freeMint() public {
        require(!paused, "the contract is paused");

        uint256 quantity = freeMintQuantity(msg.sender);
        uint256 supply = totalSupply();

        require(supply + quantity <= maxSupply, "max NFT limit exceeded");
        require(quantity > 0, "No free mints available for this account.");

        _mint(msg.sender, quantity);
        freeMints[msg.sender] = 0;
    }

    function freeMintQuantity(address _address) public view returns (uint256) {
        return freeMints[_address];
    }

    function isWhitelisted(address _user) public view returns (bool) {
        return whitelistedAddresses[_user];
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if(revealed == false) {
            return string(abi.encodePacked(notRevealedUri, tokenId.toString()));
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString()))
        : "";
    }

    function airdrop(address _address, uint256 quantity) public onlyOwner {
        uint256 supply = totalSupply();
        require(supply + quantity <= maxSupply, "max NFT limit exceeded");

        _mint(_address, quantity);
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function setCosts(uint256 _cost1, uint256 _cost2, uint256 _cost3, uint256 _cost4) public onlyOwner {
        cost1 = _cost1;
        cost2 = _cost2;
        cost3 = _cost3;
        cost4 = _cost4;
    }

    function setWhitelistedPricePercentage(uint256 _whitelistedPricePercentage) public onlyOwner {
        whitelistedPricePercentage = _whitelistedPricePercentage;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhitelisted = _state;
    }

    function setFreeMints(address[] calldata _freeMints, uint[] calldata _quantity) public onlyOwner {
        for(uint256 i = 0; i < _freeMints.length; i++) {
            freeMints[_freeMints[i]] = _quantity[i];
        }
    }

    function setWhitelistedAddresses(address[] calldata _whitelistedAddresses, bool _isWhitelisted) public onlyOwner {
        for(uint256 i = 0; i < _whitelistedAddresses.length; i++) {
            whitelistedAddresses[_whitelistedAddresses[i]] = _isWhitelisted;
        }
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}