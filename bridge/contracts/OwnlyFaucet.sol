// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OwnlyFaucet is Ownable {
    IERC20 ownToken;
    address sender;

    constructor() {
        ownToken = IERC20(0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE);
        sender = 0x768532c218f4f4e6E4960ceeA7F5a7A947a1dd61;
    }

    function setSender(address _sender) public onlyOwner virtual {
        sender = _sender;
    }

    function setOwnToken(address _ownTokenAddress) public onlyOwner virtual {
        ownToken = IERC20(_ownTokenAddress);
    }

    function claim() public {
        ownToken.transferFrom(sender, msg.sender, 1000000000000000000000);
    }
}