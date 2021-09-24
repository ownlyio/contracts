// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

abstract contract NftInterface {
    function getApproved(uint256 tokenId) public view virtual returns (
        address approved
    );
    function ownerOf(uint256 tokenId) public view virtual returns (
        address owner
    );
}

abstract contract OwnlyInterface {
    function allowance(address owner, address spender) public view virtual returns (uint256);
}

abstract contract SparkSwapRouterInterface {
    function getAmountsIn(uint amountOut, address[] memory path) public view virtual override returns (uint[] memory);
}

contract Marketplace is Initializable, OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter _itemIds;
    CountersUpgradeable.Counter _itemsSold;

    address payable marketplaceOwner;
    address OWNLY_ADDRESS = 0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE;
    address SPARKSWAP_ADDRESS = 0xeB98E6e5D34c94F56708133579abB8a6A2aC2F26;
    uint256 listingPrice;

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        string currency;
        uint256 listingPrice;
        bool cancelled;
    }

    mapping(uint256 => MarketItem) idToMarketItem;

    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        string currency,
        uint256 listingPrice
    );

    event MarketItemCancelled (
        uint indexed itemId
    );

    event MarketItemSold (
        uint indexed itemId
    );

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        marketplaceOwner = payable(0x768532c218f4f4e6E4960ceeA7F5a7A947a1dd61);
        listingPrice = 0;
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    function getListingPrice() public view virtual returns (uint256) {
        return listingPrice;
    }

    function setListingPrice(uint256 _listingPrice) public onlyOwner virtual {
        listingPrice = _listingPrice;
    }

    function getMarketItem(uint256 marketItemId) public view virtual returns (MarketItem memory) {
        return idToMarketItem[marketItemId];
    }

    function createMarketItem(address nftContractAddress, uint256 tokenId, uint256 price, string memory currency) public virtual payable nonReentrant {
        NftInterface nftContract = NftInterface(nftContractAddress);
        address nftOwner = nftContract.ownerOf(tokenId);
        address nftApproved = nftContract.getApproved(tokenId);

        require(compareStrings(currency, "BNB") || compareStrings(currency, "OWN"), "Invalid price currency");
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
            currency,
            listingPrice,
            false
        );

        emit MarketItemCreated(
            itemId,
            nftContractAddress,
            tokenId,
            msg.sender,
            price,
            currency,
            listingPrice
        );
    }

    function createMarketSale(uint256 itemId, string currency) public virtual payable nonReentrant returns (uint) {
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;

        if(compareStrings(currency, "BNB") && compareStrings(idToMarketItem[itemId].currency, "BNB")) {
            require(msg.value == price, "Please submit the asking price in order to complete the purchase");
            idToMarketItem[itemId].seller.transfer(msg.value);
        }

        if(compareStrings(currency, "OWN") && compareStrings(idToMarketItem[itemId].currency, "OWN")) {
            OwnlyInterface ownlyContract = OwnlyInterface(OWNLY_ADDRESS);
            uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

            require(idToMarketItem[itemId].price == ownlyAllowance, "Please submit the asking price in order to complete the purchase");

            IERC20Upgradeable(OWNLY_ADDRESS).transferFrom(msg.sender, idToMarketItem[itemId].seller, idToMarketItem[itemId].price);
        }

        if(compareStrings(currency, "OWN") && compareStrings(idToMarketItem[itemId].currency, "BNB")) {
            SparkSwapRouterInterface sparkSwapRouterContract = SparkSwapRouterInterface(SPARKSWAP_ADDRESS);
            sparkSwapRouterContract.getAmountsIn(idToMarketItem[itemId].price);

            OwnlyInterface ownlyContract = OwnlyInterface(OWNLY_ADDRESS);
            uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

            require(idToMarketItem[itemId].price >= ownlyAllowance, "Please submit the asking price in order to complete the purchase");

            IERC20Upgradeable(OWNLY_ADDRESS).transferFrom(msg.sender, idToMarketItem[itemId].seller, idToMarketItem[itemId].price);
        }

        IERC721Upgradeable(idToMarketItem[itemId].nftContract).transferFrom(idToMarketItem[itemId].seller, msg.sender, tokenId);
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

    function cancelMarketItem(uint256 itemId) public virtual nonReentrant {
        require(idToMarketItem[itemId].cancelled == false, "Market item is already cancelled");

        NftInterface nftContract = NftInterface(idToMarketItem[itemId].nftContract);
        address nftOwner = nftContract.ownerOf(idToMarketItem[itemId].tokenId);
        address nftApproved = nftContract.getApproved(idToMarketItem[itemId].tokenId);

        require(nftOwner == idToMarketItem[itemId].seller && nftOwner == msg.sender, "You must be the owner of the token");
        require(nftApproved == address(this), "You must give permission for this marketplace to access your token");

        idToMarketItem[itemId].cancelled = true;

        if(idToMarketItem[itemId].listingPrice > 0) {
            payable(msg.sender).transfer(idToMarketItem[itemId].listingPrice);
        }

        emit MarketItemCancelled(
            itemId
        );
    }

    function unsoldMarketItemExists(address nftContractAddress, uint256 tokenId) internal view virtual returns (bool) {
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

    function fetchMarketItem(address nftContractAddress, uint256 tokenId) public view virtual returns (MarketItem memory) {
        uint itemCount = _itemIds.current();

        MarketItem memory item;

        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].nftContract == nftContractAddress && idToMarketItem[i + 1].tokenId == tokenId && idToMarketItem[i + 1].owner == address(0) && idToMarketItem[i + 1].cancelled == false) {
                NftInterface nftContract = NftInterface(idToMarketItem[i + 1].nftContract);
                address nftOwner = nftContract.ownerOf(idToMarketItem[i + 1].tokenId);
                address nftApproved = nftContract.getApproved(idToMarketItem[i + 1].tokenId);

                if (nftOwner == idToMarketItem[i + 1].seller && nftApproved == address(this)) {
                    item = idToMarketItem[i + 1];
                    break;
                }
            }
        }

        return item;
    }

    function fetchMarketItems() public view virtual returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            NftInterface nftContract = NftInterface(idToMarketItem[i + 1].nftContract);
            address nftOwner = nftContract.ownerOf(idToMarketItem[i + 1].tokenId);
            address nftApproved = nftContract.getApproved(idToMarketItem[i + 1].tokenId);

            if (idToMarketItem[i + 1].owner == address(0) && nftOwner == idToMarketItem[i + 1].seller && nftApproved == address(this)) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view virtual returns (MarketItem[] memory) {
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

    function compareStrings(string memory a, string memory b) public view virtual returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function version() pure public virtual returns (string memory) {
        return "v1";
    }
}