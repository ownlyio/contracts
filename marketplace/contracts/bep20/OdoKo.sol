// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract OdoKo is ERC20PresetFixedSupply {
    constructor(address owner) ERC20PresetFixedSupply ("OdoKo", "ODO", 10000000000 * 10**18, owner) {}
}