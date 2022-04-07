// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract MyERC20Token is ERC20PresetFixedSupply {
    constructor(address owner) ERC20PresetFixedSupply ("MyERC20Token", "MYERC20TOKEN", 10000000000 * 10**18, owner) {}

    function getMessageHash(uint item_, uint itemId, address nftContract, uint256 tokenId, address seller, uint256 price, string memory currency, uint256 listingPrice) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(chain_id, itemId, nftContract, tokenId, seller, price, currency, listingPrice));
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

    function verify(uint chain_id, uint itemId, address nftContract, uint256 tokenId, address seller, uint256 price, string memory currency, uint256 listingPrice, bytes memory signature) public view virtual returns (bool) {
        bytes32 messageHash = getMessageHash(chain_id, itemId, nftContract, tokenId, seller, price, currency, listingPrice);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == marketplaceValidator;
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