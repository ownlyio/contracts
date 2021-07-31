// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./Marketplace.sol";

contract MarketplaceV2 is Marketplace {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _itemIds;
    CountersUpgradeable.Counter private _itemsSold;

    mapping(uint256 => MarketItem) private idToMarketItem;

    function version() pure public virtual override returns (string memory) {
        return "v2";
    }
}