// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract WrappedOwnly is ERC20, ERC20Burnable, Pausable, Ownable {
    address bridgeValidator;

    mapping(uint => bool) itemIdIsClaimed;

    constructor() ERC20("Wrapped Ownly", "wOWN") {}

    function getItemIdIsClaimed(uint itemId) public view returns (bool) {
        return itemIdIsClaimed[itemId];
    }

    function claim(uint itemId, address account, uint amount, bytes memory signature) public onlyOwner whenNotPaused {
        require(account == msg.sender, "Account is not valid for this transaction.");
        require(itemIdIsClaimed[itemId] == false, "Bridge Item is already claimed");
        require(verify(itemId, account, amount, signature) == true, "Signature is invalid.");

        itemIdIsClaimed[itemId] = true;

        _mint(account, amount);
    }

    function setBridgeValidator(address _bridgeValidator) public onlyOwner virtual {
        bridgeValidator = _bridgeValidator;
    }

    function getBridgeValidator() public view virtual returns (address) {
        return bridgeValidator;
    }

    function getMessageHash(uint itemId, address account, uint amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(itemId, account, amount));
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

    function verify(uint itemId, address account, uint amount, bytes memory signature) public view virtual returns (bool) {
        bytes32 messageHash = getMessageHash(itemId, account, amount);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == bridgeValidator;
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