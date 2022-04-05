// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MainBridge is Pausable, wnable {
    using Counter for Counters.Counter;
    Counters.Counter _itemIds;

    IERC20 ownToken;

    struct BridgeItem {
        uint itemId;
        address account;
        uint amount;
    }

    mapping(uint256 => BridgeItem) idToBridgeItem;

    event BridgeItemCreated (
        uint indexed itemId,
        address indexed account,
        uint indexed amount
    );

    function setOwnToken(uint _ownToken) public onlyOwner virtual {
        ownToken = IERC20(_ownToken);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function bridge(uint amount) public payable whenNotPaused {
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

        emit BridgeItemItemCreated(
            itemId,
            msg.sender,
            amount
        );
    }

    function fetchBridgeItems() public view virtual returns (BridgeItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint bridgeItemsCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < idToBridgeItem.length; i++) {
            if(idToBridgeItem[i].account == msg.sender) {
                bridgeItemsCount++;
            }
        }

        BridgeItem[] memory items = new BridgeItem[](bridgeItemsCount);
        for (uint i = 0; i < itemCount; i++) {
            if(idToBridgeItem[i].account == msg.sender) {
                uint currentId = idToMarketItem[i].itemId;
                BridgeItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }

        return items;
    }
}