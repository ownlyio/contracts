// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MustachioVerseAssets is ERC1155, ReentrancyGuard, Ownable {
    address payable admin = payable(0x88A14AF453b14070B9B943eea32bf3F534dFa01a);
    // address payable admin = payable(0x672b733C5350034Ccbd265AA7636C3eBDDA2223B);

    string private baseUri = "https://ownly.tk/api/mustachioverse_asset/";
    string private _name;
    string private _symbol;

    struct MintGroupDetails {
        uint256 fromId;
        uint256 to;
        uint256 price;
        uint256 edition;
    }

    mapping(uint256 => mapping(uint256 => uint256)) public mintedPerToken;
    mapping(uint256 => MintGroupDetails) public mintTokenDetails;

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

    // ------------------------------------------------------------------------
    // Get the group's assigned edition
    // ------------------------------------------------------------------------
    function getGroupEdition(uint256 _groupId, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        require(
            checkTokenIdIfInRange(_groupId, _tokenId),
            "Token ID does not belong to the group"
        );

        return mintTokenDetails[_groupId].edition;
    }

    // ------------------------------------------------------------------------
    // Get the group's assigned price
    // ------------------------------------------------------------------------
    function getGroupPrice(uint256 _groupId, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        require(
            checkTokenIdIfInRange(_groupId, _tokenId) == true,
            "Token ID does not belong to the group"
        );

        return mintTokenDetails[_groupId].price;
    }

    // ------------------------------------------------------------------------
    // Get the token's current edition count on a specific group
    // ------------------------------------------------------------------------
    function getCurrentTokenEdition(uint256 _groupId, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        return mintedPerToken[_groupId][_tokenId];
    }

    // Write Contract

    // ------------------------------------------------------------------------
    // Create a new group in the contract
    // @param _groupId The ID of the group
    // @param _fromId The Token ID number wherein the group will start
    // @param _to The Token ID number wherein the group will end
    // @param _price The price of each token in the group
    // @param _price The edition of each token in the group
    // ------------------------------------------------------------------------
    function createNewGroup(
        uint256 _groupId,
        uint256 _fromId,
        uint256 _to,
        uint256 _price,
        uint256 _edition
    ) public onlyOwner {
        require(mintTokenDetails[_groupId].fromId == 0, "Duplicate group id");
        require(_fromId < _to, "FromID must be less than to");
        require(_price > 0, "Price must not be equal to zero");
        require(_edition > 0, "Edition should be more than zero");
        mintTokenDetails[_groupId].fromId = _fromId;
        mintTokenDetails[_groupId].to = _to;
        mintTokenDetails[_groupId].price = _price;
        mintTokenDetails[_groupId].edition = _edition;
    }

    function setURI(string memory _newUri) public onlyOwner {
        _setURI(_newUri);
    }

    // ------------------------------------------------------------------------
    // Set or replace the current edition of a specific group
    // ------------------------------------------------------------------------
    function setGroupTokenEdition(uint256 _groupId, uint256 _edition)
        public
        onlyOwner
    {
        mintTokenDetails[_groupId].edition = _edition;
    }

    // ------------------------------------------------------------------------
    // Set or replace the current price of a specific group
    // ------------------------------------------------------------------------
    function setGroupMintPrice(uint256 _groupId, uint256 _price)
        public
        onlyOwner
    {
        require(_price > 0, "Price must not be equal to zero");

        mintTokenDetails[_groupId].price = _price;
    }

    // ------------------------------------------------------------------------
    // Set or replace the current range of Token IDs of a specific group
    // ------------------------------------------------------------------------
    function setGroupTokenRange(
        uint256 _groupId,
        uint256 _fromId,
        uint256 _to
    ) public onlyOwner {
        require(
            _fromId > 0 && _to > 0,
            "FromId and/or To should be more than zero"
        );
        mintTokenDetails[_groupId].fromId = _fromId;
        mintTokenDetails[_groupId].to = _to;
    }

    function mintAssetRewards(
        address _address,
        uint256 _groupId,
        uint256 _tokenId,
        uint256 _quantity
    ) public virtual onlyOwner {
        require(_quantity > 0, "Please submit an amount greater than 0");
        require(
            _quantity + mintedPerToken[_groupId][_tokenId] <=
                mintTokenDetails[_groupId].edition,
            "Amount exceeded the total edition per token."
        );

        // admin.transfer(msg.value);
        _mint(_address, _tokenId, _quantity, "0x0");
        mintedPerToken[_groupId][_tokenId] =
            mintedPerToken[_groupId][_tokenId] +
            _quantity;
    }

    function mintAsset(uint256 _groupId, uint256 _tokenId)
        public
        payable
        virtual
        nonReentrant
    {
        require(
            msg.value == getGroupPrice(_groupId, _tokenId),
            "Please submit the asking price in order to complete the purchase."
        );
        require(
            mintedPerToken[_groupId][_tokenId] <
                getGroupEdition(_groupId, _tokenId),
            "Maximum mint per token reached."
        );

        // admin.transfer(msg.value);
        _mint(msg.sender, _tokenId, 1, "0x0");
        mintedPerToken[_groupId][_tokenId]++;
    }

    // Utilities

    // ------------------------------------------------------------------------
    // Get the current range of a specific group
    // ------------------------------------------------------------------------
    function getGroupRange(uint256 _groupId)
        public
        view
        returns (string memory)
    {
        string memory fromStrId = Strings.toString(
            mintTokenDetails[_groupId].fromId
        );
        string memory toStrId = Strings.toString(mintTokenDetails[_groupId].to);

        return string(abi.encodePacked(fromStrId, " ", toStrId));
    }

    // ------------------------------------------------------------------------
    // Checks if the Token ID specified is within the
    // range of the specified group
    // ------------------------------------------------------------------------
    function checkTokenIdIfInRange(uint256 _groupId, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        return
            mintTokenDetails[_groupId].fromId <= _tokenId &&
            mintTokenDetails[_groupId].to >= _tokenId;
    }
}
