// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MainBridge is Pausable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter _itemIds;

    IERC20 ownToken;

    struct BridgeItem {
        uint itemId;
        address account;
        uint amount;
    }

    mapping(uint => BridgeItem) idToBridgeItem;
    mapping(address => uint[]) accountBridgeItemIds;

    event BridgeItemCreated (
        uint indexed itemId,
        address indexed account,
        uint indexed amount
    );

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
        uint allowance = ownToken.allowance(msg.sender, address(this));

        require(allowance >= amount, "Please submit the asking price in order to complete the purchase.");
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
}