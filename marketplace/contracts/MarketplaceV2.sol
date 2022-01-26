// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./Marketplace.sol";

abstract contract PancakeSwapRouterInterface {
    function getAmountsIn(uint amountOut, address[] memory path) public view virtual returns (uint[] memory);
}

contract MarketplaceV2 is Marketplace {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    event MarketItemPaid (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        string currency,
        uint256 listingPrice
    );

    function createMarketSale(uint256 nftChainID, uint256 itemId, string memory currency) public virtual payable nonReentrant returns (uint) {
        if(nftChainID == 56) {
            address payable seller = idToMarketItem[itemId].seller;
            uint price = idToMarketItem[itemId].price;
            uint tokenId = idToMarketItem[itemId].tokenId;
            address ownly_address = 0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE;
            //        address ownly_address = 0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA;

            if(compareStrings(currency, "BNB") && compareStrings(idToMarketItem[itemId].currency, "BNB")) {
                require(msg.value == price, "Please submit the asking price in order to complete the purchase");
                seller.transfer(msg.value);
            }

            if(compareStrings(currency, "OWN") && compareStrings(idToMarketItem[itemId].currency, "OWN")) {
                OwnlyInterface ownlyContract = OwnlyInterface(ownly_address);
                uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

                require(idToMarketItem[itemId].price == ownlyAllowance, "Please submit the asking price in order to complete the purchase");

                IERC20Upgradeable(ownly_address).transferFrom(msg.sender, seller, idToMarketItem[itemId].price);
            }

            if(compareStrings(currency, "OWN") && compareStrings(idToMarketItem[itemId].currency, "BNB")) {
                SparkSwapRouterInterface sparkSwapRouterContract = SparkSwapRouterInterface(0xeB98E6e5D34c94F56708133579abB8a6A2aC2F26);

                address[] memory path = new address[](2);
                path[0] = ownly_address;
                path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

                uint[] memory ownPrice = sparkSwapRouterContract.getAmountsIn(price, path);

                OwnlyInterface ownlyContract = OwnlyInterface(ownly_address);
                uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

                uint finalPrice = ownPrice[0];
                finalPrice = (finalPrice * 8) / 10;

                require(ownlyAllowance >= finalPrice, "Please submit the asking price in order to complete the purchase");

                IERC20Upgradeable(ownly_address).transferFrom(msg.sender, seller, finalPrice);
            }

            IERC721Upgradeable(idToMarketItem[itemId].nftContract).transferFrom(seller, msg.sender, tokenId);
            idToMarketItem[itemId].owner = payable(msg.sender);
            _itemsSold.increment();

            if(idToMarketItem[itemId].listingPrice > 0) {
                payable(marketplaceOwner).transfer(idToMarketItem[itemId].listingPrice);
            }

            emit MarketItemSold(
                itemId
            );
        } else if(nftChainID == 1) {
//            IERC20Upgradeable(ownly_address).transferFrom(msg.sender, seller, finalPrice);
            payable(marketplaceOwner).transfer(idToMarketItem[itemId].listingPrice);
        }

        return 0;
    }

    function ethToOWNConversion(uint256 amount) public view virtual returns (uint256) {
        PancakeSwapRouterInterface pancakeSwapRouterContract = PancakeSwapRouterInterface(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        address memory own_address = 0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA;
        address memory busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address memory eth_address = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;

        uint[] memory busdPrice = pancakeSwapRouterContract.getAmountsIn(amount, [busd_address, eth_address]);
        uint[] memory ownPrice = pancakeSwapRouterContract.getAmountsIn(busdPrice[0], [own_address, busd_address]);

        return ownPrice[0];
    }

    function version() pure public virtual override returns (string memory) {
        return "v2";
    }
}