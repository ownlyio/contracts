// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./Marketplace.sol";

contract MarketplaceV2 is Marketplace {
    function initializev2() onlyOwner public {

    }

    function version() pure public virtual override returns (string memory) {
        return "v2";
    }
}