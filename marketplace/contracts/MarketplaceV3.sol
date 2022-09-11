// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./MarketplaceV2.sol";

contract MarketplaceV3 is MarketplaceV2 {
    function createMarketSaleV2(uint256 itemId, string memory currency) public virtual payable nonReentrant returns (uint) {
        MarketItemV2 memory marketItem = idToMarketItemV2[itemId];

        require(marketItem.cancelled == false, "Market item is already cancelled.");
        require(marketItem.owner == address(0), "Market item is already sold.");
        require(compareStrings(currency, "BNB") || compareStrings(currency, "OWN"), "Invalid price currency.");

        if(getIdToAddressListIsOnlyAllowed(marketItem.idToAddressList)) {
            require(getIsInAddressList(marketItem.idToAddressList, msg.sender), "Only those in the whitelist can purchase.");
        }

        if(compareStrings(currency, "BNB") && compareStrings(marketItem.currency, "BNB")) {
            require(msg.value == marketItem.price, "Please submit the asking price in order to complete the purchase.");
            marketItem.seller.transfer(msg.value);
        } else if(compareStrings(currency, "OWN") && compareStrings(marketItem.currency, "OWN")) {
            IERC20Upgradeable ownlyContract = IERC20Upgradeable(ownlyAddress);

            uint totalDiscountPercentage = marketItem.discountPercentage + getAddressListDiscountPercentage(marketItem.idToAddressList, msg.sender);
            uint finalPrice = (marketItem.price * (100 - totalDiscountPercentage)) / 100;

            ownlyContract.transferFrom(msg.sender, marketItem.seller, finalPrice);
        } else if(compareStrings(currency, "OWN") && compareStrings(marketItem.currency, "BNB")) {
            //            ISparkSwapRouter pancakeSwapRouterContract = ISparkSwapRouter(0xeB98E6e5D34c94F56708133579abB8a6A2aC2F26);
            //
            //            address[] memory path = new address[](2);
            //            path[0] = ownlyAddress;
            //            path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
            //
            //            uint[] memory ownPrice = pancakeSwapRouterContract.getAmountsIn(marketItem.price, path);
            //            uint finalPrice = (ownPrice[0] * (100 - marketItem.discountPercentage)) / 100;

            uint finalPrice = (5000000000000000000000000 * (100 - marketItem.discountPercentage)) / 100;

            IERC20Upgradeable ownlyContract = IERC20Upgradeable(ownlyAddress);
            ownlyContract.transferFrom(msg.sender, marketItem.seller, finalPrice);
        } else if(compareStrings(currency, "BNB") && compareStrings(marketItem.currency, "OWN")) {
            //            ISparkSwapRouter pancakeSwapRouterContract = ISparkSwapRouter(0xeB98E6e5D34c94F56708133579abB8a6A2aC2F26);
            //
            //            address[] memory path = new address[](2);
            //            path[0] = ownlyAddress;
            //            path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
            //
            //            uint[] memory bnbPrice = pancakeSwapRouterContract.getAmountsOut(marketItem.price, path);
            //            uint price = bnbPrice[1];

            uint price = 100000000000000000;
            price = price - 3000000000000000;

            require(msg.value >= price, "Please submit the asking price in order to complete the purchase.");
            marketItem.seller.transfer(msg.value);
        }

        IERC721Upgradeable(marketItem.nftContract).transferFrom(marketItem.seller, msg.sender, marketItem.tokenId);
        idToMarketItemV2[itemId].owner = payable(msg.sender);
        _itemsSold.increment();

        if(marketItem.listingPrice > 0) {
            payable(marketplaceOwner).transfer(marketItem.listingPrice);
        }

        emit MarketItemSoldV2(
            itemId
        );

        return 0;
    }

    function cancelMarketItemV2(uint256 itemId) public virtual nonReentrant {
        MarketItemV2 memory marketItem = idToMarketItemV2[itemId];

        require(marketItem.seller == msg.sender, "You do not own this market item.");
        require(marketItem.cancelled == false, "Market item is already cancelled.");

        IERC721Upgradeable nftContract = IERC721Upgradeable(marketItem.nftContract);
        address nftOwner = nftContract.ownerOf(marketItem.tokenId);
        bool isApprovedForAll = nftContract.isApprovedForAll(nftOwner, address(this));

        require(marketItem.owner == address(0), "This market item is already sold.");
        require(nftOwner == marketItem.seller, "You must be the owner of the token.");
        require(isApprovedForAll, "You must give permission for this marketplace to access your token.");

        idToMarketItemV2[itemId].cancelled = true;

        if(idToMarketItemV2[itemId].listingPrice > 0) {
            payable(msg.sender).transfer(idToMarketItemV2[itemId].listingPrice);
        }

        emit MarketItemCancelledV2(
            itemId
        );
    }

    function version() pure public virtual override returns (string memory) {
        return "v3";
    }
}