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
    uint256 freeMintCount;
    uint256 whitelistedAddressesCount;
    bool public paused = false;
    bool public revealed = false;
    bool public onlyWhitelisted = true;
    address validator;

    mapping(uint => address) freeMints;
    mapping(uint => address) whitelistedAddresses;

    mapping(uint => bool) freeMintIsClaimed;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri,
        address _validator
    ) ERC721A(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
        setValidator(_validator);
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

        for(uint256 i = 1; i <= freeMintCount; i++) {
            if(freeMints[i] == msg.sender && !freeMintIsClaimed[i]) {
                freeMintIsClaimed[i] = true;
            }
        }
    }

    function freeMintQuantity(address _address) public view returns (uint256) {
        uint256 quantity = 0;

        for(uint256 i = 1; i <= freeMintCount; i++) {
            if(freeMints[i] == _address && !freeMintIsClaimed[i]) {
                quantity++;
            }
        }

        return quantity;
    }

    function isWhitelisted(address _user) public view returns (bool) {
        bool _isWhitelisted = false;

        for(uint256 i = 1; i <= whitelistedAddressesCount; i++) {
            if(whitelistedAddresses[i] == _user) {
                _isWhitelisted = true;
                break;
            }
        }

        return _isWhitelisted;
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

    function setFreeMints(address[] calldata _freeMints, bool overwrite) public onlyOwner {
        freeMintCount = _freeMints.length;

        for(uint256 i = 1; i <= freeMintCount; i++) {
            if(overwrite) {
                freeMints[i] = _freeMints[i];
            } else {
                if(freeMints[i] == address(0)) {
                    freeMints[i] = _freeMints[i];
                }
            }
        }
    }

    function setWhitelistedAddresses(address[] calldata _whitelistedAddresses, bool overwrite) public onlyOwner {
        whitelistedAddressesCount = _whitelistedAddresses.length;

        for(uint256 i = 1; i <= whitelistedAddressesCount; i++) {
            if(overwrite) {
                whitelistedAddresses[i] = _whitelistedAddresses[i];
            } else {
                if(whitelistedAddresses[i] == address(0)) {
                    whitelistedAddresses[i] = _whitelistedAddresses[i];
                }
            }
        }
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function setValidator(address _validator) public onlyOwner virtual {
        validator = _validator;
    }

    function verify(address account, bytes memory signature) public view virtual returns (bool) {
        bytes32 messageHash = getMessageHash(account);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == validator;
    }

    function getMessageHash(address account) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure virtual returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
        keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure virtual returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure virtual returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
        /*
        First 32 bytes stores the length of the signature

        add(sig, 32) = pointer of sig + 32
        effectively, skips first 32 bytes of signature

        mload(p) loads next 32 bytes starting at the memory address p into memory
        */

        // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
        // second 32 bytes
            s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}