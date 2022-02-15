// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

abstract contract INFTStaking {
    function setStakingItemAsClaimed(uint idToStakingItem) public virtual;
    function getStakingItemAccount(uint stakingItemId) public view virtual returns (address);
    function getStakingItemAmount(uint stakingItemId) public view virtual returns (uint);
    function getStakingItemDeadline(uint stakingItemId) public view virtual returns (uint);
    function getStakingItemIsClaimed(uint stakingItemId) public view virtual returns (bool);
}

contract NFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    string public PROVENANCE_HASH = "";
    string baseUri = "https://ownly.io/nft/sample/api/";

    uint mintPrice;
    uint stakeRequired;
    uint stakeDuration;

    address payable admin;

    struct StakingItem {
        address account;
        uint amount;
        uint deadline;
        bool isClaimed;
    }

    constructor() ERC721("NFT", "NFT") {}

    function setMintPrice(uint _mintPrice) public onlyOwner virtual {
        mintPrice = _mintPrice;
    }

    function getMintPrice() public view virtual returns (uint) {
        return mintPrice;
    }

    function setStakeRequired(uint _stakeRequired) public onlyOwner virtual {
        stakeRequired = _stakeRequired;
    }

    function getStakeRequired() public view virtual returns (uint) {
        return stakeRequired;
    }

    function setStakeDuration(uint _stakeDuration) public onlyOwner virtual {
        stakeDuration = _stakeDuration;
    }

    function getStakeDuration() public view virtual returns (uint) {
        return stakeDuration;
    }

    function setAdmin(address payable _admin) public onlyOwner virtual {
        admin = _admin;
    }

    function getAdmin() public view virtual returns (address) {
        return admin;
    }

    function mintMultiple(address[] memory _addresses) public onlyOwner {
        for(uint i = 0; i < _addresses.length; i++) {
            mintNFT(_addresses[i]);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function setBaseUri(string memory _baseUri) public onlyOwner {
        baseUri = _baseUri;
    }

    function setProvenanceHash(string memory _provenanceHash) external onlyOwner {
        PROVENANCE_HASH = _provenanceHash;
    }

    function purchaseMint() public nonReentrant {
        address ownly_address = 0xC3Df366fAf79c6Caff3C70948363f00b9Ac55FEE;
        //        address ownly_address = 0x7665CB7b0d01Df1c9f9B9cC66019F00aBD6959bA;

        IERC20 stakingTokenContract = IERC20(ownly_address);
        uint allowance = stakingTokenContract.allowance(msg.sender, address(this));

        require(mintPrice >= allowance, "Please submit the asking price in order to complete the purchase");

        stakingTokenContract.transferFrom(msg.sender, admin, mintPrice);

        mintNFT(msg.sender);
    }

    function stakeMint(address nftStakingAddress, uint stakingItemId) public nonReentrant {
        INFTStaking nftStaking = INFTStaking(nftStakingAddress);

        address stakingItemAccount = nftStaking.getStakingItemAccount(stakingItemId);
        uint stakingItemAmount = nftStaking.getStakingItemAmount(stakingItemId);
        uint stakingItemDeadline = nftStaking.getStakingItemDeadline(stakingItemId);
        bool stakingItemIsClaimed = nftStaking.getStakingItemIsClaimed(stakingItemId);

        require(stakingItemAccount == msg.sender, "Current account is not valid for this staking item.");
        require(stakingItemAmount >= stakeRequired, "Staking amount is invalid.");
        require(block.timestamp >= stakingItemDeadline, "Staking duration is not finish yet.");
        require(!stakingItemIsClaimed, "Staking item is already claimed.");

        nftStaking.setStakingItemAsClaimed(stakingItemId);

        mintNFT(msg.sender);
    }

    function mintNFT(address _address) internal {
        tokenIds.increment();
        uint tokenId = tokenIds.current();
        _mint(_address, tokenId);
    }
}