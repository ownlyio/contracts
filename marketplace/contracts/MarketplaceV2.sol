// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./Marketplace.sol";

abstract contract ISparkSwapRouter {
    function getAmountsIn(uint amountOut, address[] calldata path) external view virtual returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view virtual returns (uint[] memory amounts);
}

contract MarketplaceV2 is Marketplace {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter _itemIdsV2;
    CountersUpgradeable.Counter _itemsSoldV2;

    address ownlyAddress;

    struct MarketItemV2 {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        string currency;
        uint discountPercentage;
        uint idToAddressList;
        uint256 listingPrice;
        bool cancelled;
    }

    mapping(uint256 => MarketItemV2) idToMarketItemV2;

    mapping(uint256 => address[]) idToAddressList;
    mapping(uint256 => uint256) idToAddressListDiscountPercentage;
    mapping(uint256 => bool) idToAddressListIsOnlyAllowed;

    event MarketItemCreatedV2 (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        string currency,
        uint discountPercentage,
        uint idToAddressList,
        uint256 listingPrice
    );

    event MarketItemCancelledV2 (
        uint indexed itemId
    );

    event MarketItemSoldV2 (
        uint indexed itemId
    );

    function createMarketSale(uint256 itemId, string memory currency) public virtual payable override nonReentrant returns (uint) {
        address payable seller = idToMarketItem[itemId].seller;
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        require(compareStrings(currency, "BNB") || compareStrings(currency, "OWN"), "Invalid price currency.");

        if(compareStrings(currency, "BNB") && compareStrings(idToMarketItem[itemId].currency, "BNB")) {
            require(msg.value == price, "Please submit the asking price in order to complete the purchase");
            seller.transfer(msg.value);
        }

        if(compareStrings(currency, "OWN") && compareStrings(idToMarketItem[itemId].currency, "OWN")) {
            OwnlyInterface ownlyContract = OwnlyInterface(ownlyAddress);
            uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

            require(idToMarketItem[itemId].price == ownlyAllowance, "Please submit the asking price in order to complete the purchase");

            IERC20Upgradeable(ownlyAddress).transferFrom(msg.sender, seller, idToMarketItem[itemId].price);
        }

        if(compareStrings(currency, "OWN") && compareStrings(idToMarketItem[itemId].currency, "BNB")) {
            SparkSwapRouterInterface sparkSwapRouterContract = SparkSwapRouterInterface(0xeB98E6e5D34c94F56708133579abB8a6A2aC2F26);

            address[] memory path = new address[](2);
            path[0] = ownlyAddress;
            path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

            uint[] memory ownPrice = sparkSwapRouterContract.getAmountsIn(price, path);

            OwnlyInterface ownlyContract = OwnlyInterface(ownlyAddress);
            uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

            uint finalPrice = ownPrice[0];
            finalPrice = (finalPrice * 8) / 10;

            require(ownlyAllowance >= finalPrice, "Please submit the asking price in order to complete the purchase");

            IERC20Upgradeable(ownlyAddress).transferFrom(msg.sender, seller, finalPrice);
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

        return 2;
    }

    function getOwnlyAddress() public view virtual returns (address) {
        return ownlyAddress;
    }

    function setOwnlyAddress(address _ownlyAddress) public onlyOwner virtual {
        ownlyAddress = _ownlyAddress;
    }

    function getMarketItemV2(uint256 itemId) public view virtual returns (MarketItemV2 memory) {
        return idToMarketItemV2[itemId];
    }

    function createMarketItemV2(address nftContractAddress, uint256 tokenId, uint256 price, string memory currency, uint256 discountPercentage, uint256 _idToAddressList) public virtual payable nonReentrant {
        IERC721Upgradeable nftContract = IERC721Upgradeable(nftContractAddress);
        address nftOwner = nftContract.ownerOf(tokenId);
        bool isApprovedForAll = nftContract.isApprovedForAll(nftOwner, address(this));

        require(compareStrings(currency, "BNB") || compareStrings(currency, "OWN"), "Invalid price currency.");
        require(nftOwner == msg.sender, "You must be the owner of the token.");
        require(isApprovedForAll, "You must give permission for this marketplace to access your token.");
        require(price > 0, "Price must be at least 1 wei.");
        require(msg.value == listingPrice, "Value must be equal to listing price.");
        require(discountPercentage < 100, "Invalid discount percentage.");

        MarketItemV2 memory marketItemV2 = fetchMarketItemV2(nftContractAddress, tokenId);
        require(marketItemV2.itemId == 0, "Market item already exists.");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItemV2[itemId] = MarketItemV2(
            itemId,
            nftContractAddress,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            currency,
            discountPercentage,
            _idToAddressList,
            listingPrice,
            false
        );

        emit MarketItemCreatedV2(
            itemId,
            nftContractAddress,
            tokenId,
            msg.sender,
            price,
            currency,
            discountPercentage,
            _idToAddressList,
            listingPrice
        );
    }

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
        idToMarketItem[itemId].owner = payable(msg.sender);
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

        if(idToMarketItem[itemId].listingPrice > 0) {
            payable(msg.sender).transfer(idToMarketItem[itemId].listingPrice);
        }

        emit MarketItemCancelledV2(
            itemId
        );
    }

    function fetchMarketItemV2(address nftContractAddress, uint256 tokenId) public view virtual returns (MarketItemV2 memory) {
        uint itemCount = _itemIds.current();

        MarketItemV2 memory item;

        for (uint i = 1; i <= itemCount; i++) {
            MarketItemV2 memory marketItem = idToMarketItemV2[i];

            if (marketItem.nftContract == nftContractAddress && marketItem.tokenId == tokenId && marketItem.owner == address(0) && marketItem.cancelled == false) {
                IERC721Upgradeable nftContract = IERC721Upgradeable(marketItem.nftContract);
                address nftOwner = nftContract.ownerOf(marketItem.tokenId);
                bool isApprovedForAll = nftContract.isApprovedForAll(nftOwner, address(this));

                if (nftOwner == marketItem.seller && isApprovedForAll) {
                    item = marketItem;
                    break;
                }
            }
        }

        return item;
    }

    function getIsInAddressList(uint id, address _user) public view returns (bool) {
        bool isInAddressList = false;

        for (uint i = 0; i < idToAddressList[id].length; i++) {
            if (idToAddressList[id][i] == _user) {
                isInAddressList = true;
                break;
            }
        }

        return isInAddressList;
    }

    function getAddressListDiscountPercentage(uint id, address _user) public view returns (uint) {
        uint discountPercentage = 0;

        for (uint i = 0; i < idToAddressList[id].length; i++) {
            if (idToAddressList[id][i] == _user) {
                discountPercentage = idToAddressListDiscountPercentage[id];
                break;
            }
        }

        return discountPercentage;
    }

    function addressList(uint id, address[] calldata _addresses, uint discountPercentage) public onlyOwner {
        delete idToAddressList[id];
        idToAddressList[id] = _addresses;

        idToAddressListDiscountPercentage[id] = discountPercentage;
    }

    function getIdToAddressListIsOnlyAllowed(uint id) public view returns (bool) {
        return idToAddressListIsOnlyAllowed[id];
    }

    function setIdToAddressListIsOnlyAllowed(uint id, bool state) public onlyOwner {
        idToAddressListIsOnlyAllowed[id] = state;
    }

    function version() pure public virtual override returns (string memory) {
        return "v2";
    }
}