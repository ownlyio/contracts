// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./MarketplaceV2.sol";

contract MarketplaceV3 is MarketplaceV2 {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _itemIds;
    CountersUpgradeable.Counter private _itemsSold;

    mapping(uint256 => MarketItem) private idToMarketItem;

    function createMarketItem(address nftContractAddress, uint256 tokenId, uint256 price) public virtual override payable nonReentrant {
        NftInterface nftContract = NftInterface(nftContractAddress);
        address nftOwner = nftContract.ownerOf(tokenId);
        address nftApproved = nftContract.getApproved(tokenId);

        require(nftOwner == msg.sender, "You must be the owner of the token");
        require(nftApproved == address(this), "You must give permission for this marketplace to access your token");
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Value must be equal to listing price");

        MarketItem memory marketItem = fetchMarketItem(nftContractAddress, tokenId);
        require(marketItem.itemId == 0, "Market item already exists");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContractAddress,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            listingPrice,
            false
        );

        emit MarketItemCreated(
            itemId,
            nftContractAddress,
            tokenId,
            msg.sender,
            price,
            listingPrice
        );
    }

    function version() pure public virtual override returns (string memory) {
        return "v3";
    }
}