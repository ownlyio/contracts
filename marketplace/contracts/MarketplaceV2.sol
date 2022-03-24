// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./Marketplace.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

abstract contract PancakeSwapRouterInterface {
    function getAmountsIn(uint amountOut, address[] memory path) public view virtual returns (uint[] memory);
}

contract MarketplaceV2 is Marketplace {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    address marketplaceValidator;
    uint256 ownDiscountAmount;

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

    function setMarketplaceValidator(address _marketplaceValidator) public onlyOwner virtual {
        marketplaceValidator = _marketplaceValidator;
    }

    function getMarketplaceValidator() public view virtual returns (address) {
        return marketplaceValidator;
    }

    function setOwnDiscountAmount(uint256 _ownDiscountAmount) public onlyOwner virtual {
        ownDiscountAmount = _ownDiscountAmount;
    }

    function getOwnDiscountAmount() public view virtual returns (uint256) {
        return ownDiscountAmount;
    }

    function createMarketItem(address chainId, address nftContractAddress, uint256 tokenId, uint256 price, string memory currency) public virtual payable nonReentrant {
        IERC721Upgradeable nftContract = IERC721Upgradeable(nftContractAddress);
        address nftOwner = nftContract.ownerOf(tokenId);
        bool isApprovedForAll = nftContract.isApprovedForAll(nftOwner, address(this));

        require(compareStrings(currency, "BNB") || compareStrings(currency, "OWN"), "Invalid price currency");
        require(nftOwner == msg.sender, "You must be the owner of the token");
        require(isApprovedForAll, "You must give permission for this marketplace to access your token");
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

    function createMarketSale(uint256 itemId, string memory currency, uint256 nftChainId, address nftContract, uint256 tokenId, address seller, uint256 price, uint256 listingPrice, bytes memory signature) public virtual payable nonReentrant {
        address ownly_address = 0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE;
        //        address ownly_address = 0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA;
        string memory _currency = currency;


//        if(nftChainId == 56) {  // mainnet
        if(nftChainId == 97) {  // testnet
            MarketItem memory marketItem = idToMarketItem[itemId];

            if(compareStrings(currency, "BNB") && compareStrings(marketItem.currency, "BNB")) {
                require(msg.value == marketItem.price, "Please submit the asking price in order to complete the purchase");
                marketItem.seller.transfer(msg.value);
            }

            if(compareStrings(currency, "OWN") && compareStrings(marketItem.currency, "OWN")) {
                IERC20Upgradeable ownlyContract = IERC20Upgradeable(ownly_address);
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

                IERC20Upgradeable ownlyContract = IERC20Upgradeable(ownly_address);
                uint ownlyAllowance = ownlyContract.allowance(msg.sender, address(this));

                uint finalPrice = getOwnDiscountedAmount(ownPrice[0]);

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
//        } else if(nftChainId == 1) { // mainnet
        } else if(nftChainId == 4) { // testnet
            require(verify(nftChainId, itemId, nftContract, tokenId, seller, price, _currency, listingPrice, signature), "Invalid Market Item");

            // mainnet
//            uint ownPrice = getOwnDiscountedAmount(ethToOWNConversion(price));

            // testnet
            uint ownPrice = getOwnDiscountedAmount(1000000000000000000000);
            ownPrice = (ownPrice * 8) / 10; // 20% discount

            IERC20Upgradeable(ownly_address).transferFrom(msg.sender, seller, ownPrice);
            payable(marketplaceOwner).transfer(idToMarketItem[itemId].listingPrice);

            emit MarketItemPaidForOtherChain(
                nftChainId,
                itemId,
                nftContract,
                tokenId,
                seller,
                ownPrice,
                _currency,
                listingPrice
            );
        }
    }

    function getOwnDiscountedAmount(uint256 amount) public view virtual returns (uint256) {
        return (amount * (100 - ownDiscountAmount)) / 100; // 20% discount
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

    function getMessageHash(uint chain_id, uint itemId, address nftContract, uint256 tokenId, address seller, uint256 price, string memory currency, uint256 listingPrice) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(chain_id, itemId, nftContract, tokenId, seller, price, currency, listingPrice));
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

    function verify(uint chain_id, uint itemId, address nftContract, uint256 tokenId, address seller, uint256 price, string memory currency, uint256 listingPrice, bytes memory signature) public view virtual returns (bool) {
        bytes32 messageHash = getMessageHash(chain_id, itemId, nftContract, tokenId, seller, price, currency, listingPrice);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == marketplaceValidator;
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

    function version() pure public virtual override returns (string memory) {
        return "v2";
    }
}