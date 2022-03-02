// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract MyERC20Token is ERC20PresetFixedSupply {
    constructor(address owner) ERC20PresetFixedSupply ("MyERC20Token", "MYERC20TOKEN", 10000000000 * 10**18, owner) {}
}