// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./BRC721Enumerable.sol";
import "./Pausable.sol";
import "./Strings.sol";
import "./Counters.sol";

contract BNFT is BRC721Enumerable, Pausable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor() BRC721(0x768532c218f4f4e6E4960ceeA7F5a7A947a1dd61, "OdongMahamot", "ODO") {}

    function setPause() external onlyAdmin {
        _pause();
    }

    function unsetPause() external onlyAdmin {
        _unpause();
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "BRC721Pausable: token transfer while paused");
    }

    function createToken(string memory tokenURI) public onlyAdmin returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, string(abi.encodePacked(tokenURI, uint2str(newItemId))));
        return newItemId;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}