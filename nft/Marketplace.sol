// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract NftInterface {
    function getApproved(uint256 tokenId) public view virtual returns (
        address approved
    );
    function ownerOf(uint256 tokenId) public view virtual returns (
        address owner
    );
}

contract Marketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool cancelled;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );

    event MarketItemCancelled (
        uint indexed itemId
    );

    event MarketItemSold (
        uint indexed itemId
    );

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function setListingPrice(uint256 _listingPrice) public {
        listingPrice = _listingPrice;
    }

    function getMarketItem(uint256 marketItemId) public view returns (MarketItem memory) {
        return idToMarketItem[marketItemId];
    }

    function createMarketItem(
        address nftContractAddress,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        NftInterface nftContract = NftInterface(nftContractAddress);
        address nftOwner = nftContract.ownerOf(tokenId);

        require(nftOwner == msg.sender, "You must be the owner of the token");
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Value must be equal to listing price");
        require(unsoldMarketItemExists(nftContractAddress, tokenId) == false, "Market item already exists");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] =  MarketItem(
            itemId,
            nftContractAddress,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        emit MarketItemCreated(
            itemId,
            nftContractAddress,
            tokenId,
            msg.sender,
            price
        );
    }

    function createMarketSale(
        uint256 itemId
    ) public payable nonReentrant {
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(idToMarketItem[itemId].nftContract).transferFrom(idToMarketItem[itemId].seller, msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        _itemsSold.increment();

        if(listingPrice > 0) {
            payable(owner).transfer(listingPrice);
        }

        emit MarketItemSold(
            itemId
        );
    }

    function cancelMarketSale(
        uint256 itemId
    ) public {
        NftInterface nftContract = NftInterface(idToMarketItem[itemId].nftContract);
        address nftOwner = nftContract.ownerOf(idToMarketItem[itemId].tokenId);

        require(nftOwner == msg.sender, "You are not the owner of this token.");

        idToMarketItem[itemId].cancelled = false;

        emit MarketItemCancelled(
            itemId
        );
    }

    function unsoldMarketItemExists(address nftContractAddress, uint256 tokenId) internal view returns (bool) {
        MarketItem[] memory items = fetchMarketItems();
        bool exists = false;

        for (uint i = 0; i < items.length; i++) {
            if(items[i].nftContract == nftContractAddress && items[i].tokenId == tokenId) {
                exists = true;
                break;
            }
        }

        return exists;
    }

    function fetchMarketItem(address nftContractAddress, uint256 tokenId) public view returns (MarketItem memory) {
        uint itemCount = _itemIds.current();

        MarketItem memory item;

        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].nftContract == nftContractAddress && idToMarketItem[i + 1].tokenId == tokenId && idToMarketItem[i + 1].owner == address(0)) {
                NftInterface nftContract = NftInterface(idToMarketItem[i + 1].nftContract);
                address nftOwner = nftContract.ownerOf(idToMarketItem[i + 1].tokenId);

                if (idToMarketItem[i + 1].owner == address(0) && nftOwner == idToMarketItem[i + 1].seller) {
                    item = idToMarketItem[i + 1];
                    break;
                }
            }
        }

        return item;
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            NftInterface nftContract = NftInterface(idToMarketItem[i + 1].nftContract);
            address nftOwner = nftContract.ownerOf(idToMarketItem[i + 1].tokenId);

            if (idToMarketItem[i + 1].owner == address(0) && nftOwner == idToMarketItem[i + 1].seller) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
}