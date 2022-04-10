// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MainBridge is Pausable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter _itemIds;

    address bridgeValidator;

    IERC20 ownToken;

    struct BridgeItem {
        uint itemId;
        address account;
        uint amount;
    }

    mapping(uint => BridgeItem) idToBridgeItem;
    mapping(address => uint[]) accountBridgeItemIds;
    mapping(uint => mapping(uint => bool)) itemIdIsClaimed;

    event BridgeItemCreated (
        uint indexed itemId,
        address indexed account,
        uint indexed amount
    );

    constructor() {
        ownToken = IERC20(0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE);
        bridgeValidator = 0xe5B4f53Eb4c651377e0f98AF67fF506a1c5fC1C9;
    }

    function getItemIdIsClaimed(uint chainId, uint itemId) public view returns (bool) {
        return itemIdIsClaimed[chainId][itemId];
    }

    function setOwnToken(address _ownTokenAddress) public onlyOwner virtual {
        ownToken = IERC20(_ownTokenAddress);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function bridge(uint amount) public whenNotPaused {
        ownToken.transferFrom(msg.sender, address(this), amount);

        uint256 itemId = _itemIds.current();
        _itemIds.increment();

        idToBridgeItem[itemId] = BridgeItem(
            itemId,
            msg.sender,
            amount
        );

        accountBridgeItemIds[msg.sender].push(itemId);

        emit BridgeItemCreated(
            itemId,
            msg.sender,
            amount
        );
    }

    function fetchBridgeItems(address account) public view virtual returns (BridgeItem[] memory) {
        uint itemCount = accountBridgeItemIds[account].length;

        BridgeItem[] memory items = new BridgeItem[](itemCount);
        for(uint i = 0; i < itemCount; i++) {
            items[i] = idToBridgeItem[accountBridgeItemIds[account][i]];
        }

        return items;
    }

    function claim(uint chainId, address contractAddress, uint itemId, address account, uint amount, bytes memory signature) public onlyOwner whenNotPaused {
        require(account == msg.sender, "Account is not valid for this transaction.");
        require(itemIdIsClaimed[chainId][itemId] == false, "Bridge Item is already claimed.");
        require(verify(chainId, contractAddress, itemId, account, amount, signature) == true, "Signature is invalid.");

        itemIdIsClaimed[chainId][itemId] = true;

        ownToken.transfer(msg.sender, amount);
    }

    function setBridgeValidator(address _bridgeValidator) public onlyOwner virtual {
        bridgeValidator = _bridgeValidator;
    }

    function getBridgeValidator() public view virtual returns (address) {
        return bridgeValidator;
    }

    function getMessageHash(uint chainId, address contractAddress, uint itemId, address account, uint amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(chainId, contractAddress, itemId, account, amount));
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

    function verify(uint chainId, address contractAddress, uint itemId, address account, uint amount, bytes memory signature) public view virtual returns (bool) {
        bytes32 messageHash = getMessageHash(chainId, contractAddress, itemId, account, amount);
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