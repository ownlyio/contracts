// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./Marketplace.sol";

abstract contract PancakeSwapRouterInterface {
    function getAmountsIn(uint amountOut, address[] memory path) public view virtual returns (uint[] memory);
}

contract MarketplaceV2 is Marketplace {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    event MarketItemPaidForOtherChain (
        uint nftChainID,
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        string currency,
        uint256 listingPrice
    );

    function createMarketSale(uint256 itemId, string memory currency, uint256 nftChainID, address nftContract, uint256 tokenId, address seller, uint256 price, uint256 listingPrice) public virtual payable nonReentrant {
        address ownly_address = 0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE;
        //        address ownly_address = 0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA;

        if(nftChainID == 56) {
            MarketItem memory marketItem = idToMarketItem[itemId];

            if(compareStrings(currency, "BNB") && compareStrings(marketItem.currency, "BNB")) {
                require(msg.value == marketItem.price, "Please submit the asking price in order to complete the purchase");
                marketItem.seller.transfer(msg.value);
            }

            if(compareStrings(currency, "OWN") && compareStrings(marketItem.currency, "OWN")) {
                OwnlyInterface ownlyContract = OwnlyInterface(ownly_address);
                uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

                require(marketItem.price == ownlyAllowance, "Please submit the asking price in order to complete the purchase");

                IERC20Upgradeable(ownly_address).transferFrom(msg.sender, marketItem.seller, marketItem.price);
            }

            if(compareStrings(currency, "OWN") && compareStrings(marketItem.currency, "BNB")) {
                SparkSwapRouterInterface sparkSwapRouterContract = SparkSwapRouterInterface(0xeB98E6e5D34c94F56708133579abB8a6A2aC2F26);

                address[] memory path = new address[](2);
                path[0] = ownly_address;
                path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

                uint[] memory ownPrice = sparkSwapRouterContract.getAmountsIn(marketItem.price, path);

                OwnlyInterface ownlyContract = OwnlyInterface(ownly_address);
                uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

                uint finalPrice = ownPrice[0];
                finalPrice = (finalPrice * 8) / 10; // 20% discount

                require(ownlyAllowance >= finalPrice, "Please submit the asking price in order to complete the purchase");

                IERC20Upgradeable(ownly_address).transferFrom(msg.sender, marketItem.seller, finalPrice);
            }

            IERC721Upgradeable(marketItem.nftContract).transferFrom(marketItem.seller, msg.sender, marketItem.tokenId);
            idToMarketItem[itemId].owner = payable(msg.sender);
            _itemsSold.increment();

            if(marketItem.listingPrice > 0) {
                payable(marketplaceOwner).transfer(marketItem.listingPrice);
            }

            emit MarketItemSold(
                itemId
            );
        } else if(nftChainID == 1) {
            uint ownPrice = ethToOWNConversion(price);
            ownPrice = (ownPrice * 8) / 10; // 20% discount

            IERC20Upgradeable(ownly_address).transferFrom(msg.sender, seller, ownPrice);
            payable(marketplaceOwner).transfer(idToMarketItem[itemId].listingPrice);

            emit MarketItemPaidForOtherChain(
                nftChainID,
                itemId,
                nftContract,
                tokenId,
                seller,
                price,
                currency,
                listingPrice
            );
        }
    }

    function ethToOWNConversion(uint256 amount) public view virtual returns (uint256) {
        PancakeSwapRouterInterface pancakeSwapRouterContract = PancakeSwapRouterInterface(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        address own_address = 0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA;
        address busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address eth_address = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;

        address[] memory busd_eth_path = new address[](2);
        busd_eth_path[0] = busd_address;
        busd_eth_path[1] = eth_address;

        address[] memory own_busd_path = new address[](2);
        own_busd_path[0] = own_address;
        own_busd_path[1] = busd_address;

        uint[] memory busdPrice = pancakeSwapRouterContract.getAmountsIn(amount, busd_eth_path);
        uint[] memory ownPrice = pancakeSwapRouterContract.getAmountsIn(busdPrice[0], own_busd_path);

        return ownPrice[0];
    }

    function version() pure public virtual override returns (string memory) {
        return "v2";
    }
}