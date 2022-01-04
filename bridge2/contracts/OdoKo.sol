// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract OdoKo is ERC20PresetFixedSupply {
    constructor() ERC20PresetFixedSupply ("OdoKo", "ODO", 10000000000 * 10**18, 0x768532c218f4f4e6E4960ceeA7F5a7A947a1dd61) {}
}