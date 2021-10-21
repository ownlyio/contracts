// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MustachioVerseAssets is ERC1155, ReentrancyGuard, Ownable {
    address payable admin = payable(0x88A14AF453b14070B9B943eea32bf3F534dFa01a);
    // address payable admin = payable(0x672b733C5350034Ccbd265AA7636C3eBDDA2223B);

    string private baseUri = "https://ownly.tk/api/mustachio_bg/";
    string private _name;
    string private _symbol;

    struct MintGroupDetails {
        uint256 from;
        uint256 to;
        uint256 price;
        uint256 edition;
    }

    mapping(uint256 => mapping(uint256 => uint256)) private mintedPerToken;
    mapping(uint256 => MintGroupDetails) private mintTokenDetails;

    constructor() ERC1155(baseUri) {
        _name = "MustachioVerse Assets";
        _symbol = "MUSTACHIO";
    }

    // Read Contract
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return
            string(abi.encodePacked(uri(_tokenId), Strings.toString(_tokenId)));
    }

    function getGroupEdition(uint256 _groupId, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        require(
            mintTokenDetails[_groupId].from >= _tokenId &&
                mintTokenDetails[_groupId].to <= _tokenId,
            "Token ID does not belong to the group"
        );

        return mintTokenDetails[_groupId].edition;
    }

    function getGroupPrice(uint256 _groupId, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        require(
            mintTokenDetails[_groupId].from >= _tokenId &&
                mintTokenDetails[_groupId].to <= _tokenId,
            "Token ID does not belong to the group"
        );

        return mintTokenDetails[_groupId].price;
    }

    function getCurrentTokenEdition(uint256 _groupId, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        return mintedPerToken[_groupId][_tokenId];
    }

    // Write Contract
    function setURI(string memory _newUri) public onlyOwner {
        _setURI(_newUri);
    }

    function setGroupEdition(uint256 _group_id, uint256 _edition)
        public
        onlyOwner
    {
        return mintTokenDetails[_groupId].edition = _edition;
    }

    function setGroupMintPrice(uint256 _group_id, uint256 _edition)
        public
        onlyOwner
    {
        return mintTokenDetails[_groupId].price = _price;
    }

    function createNewGroup(
        uint256 _group_id,
        uint256 _from,
        uint256 _to,
        uint256 _price,
        uint256 _edition
    ) public onlyOwner {
        require(!mintTokenDetails[_group_id].price, "Duplicate group id");
        require(_from < _to, "From must be less than to");
        mintTokenDetails[_group_id].from = _from;
        mintTokenDetails[_group_id].to = _to;
        mintTokenDetails[_group_id].price = _price;
        mintTokenDetails[_group_id].edition = _edition;
    }

    function mintBackgroundRewards(
        address _address,
        uint256 _tokenId,
        uint256 _quantity
    ) public virtual onlyOwner {
        require(_quantity > 0, "Please submit an amount greater than 0");
        require(
            _quantity + mintedPerToken[_tokenId] <= edition,
            "Amount exceeded the total edition per token."
        );

        // admin.transfer(msg.value);
        _mint(_address, _tokenId, _quantity, "0x0");
        mintedPerToken[_tokenId] = mintedPerToken[_tokenId] + _quantity;
    }

    function mintBackground(uint256 _tokenId)
        public
        payable
        virtual
        nonReentrant
    {
        require(
            msg.value == mintPrice,
            "Please submit the asking price in order to complete the purchase."
        );
        require(
            mintedPerToken[_tokenId] < edition,
            "Maximum mint per token reached."
        );

        // admin.transfer(msg.value);
        _mint(msg.sender, _tokenId, 1, "0x0");
        mintedPerToken[_tokenId]++;
    }
}
