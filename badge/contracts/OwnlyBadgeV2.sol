// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./OwnlyBadge.sol";

contract OwnlyBadgeV2 is OwnlyBadge {
    constructor() {
        _disableInitializers();
    }

    function version() pure public virtual override returns (string memory) {
        return "v2";
    }
}