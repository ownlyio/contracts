// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract INFTStaking {
    function setStakingItemAsClaimed(uint idToStakingItem) public virtual;
    function getStakingItemNftContractAddress(uint stakingItemId) public view virtual returns (address);
    function getStakingItemAccount(uint stakingItemId) public view virtual returns (address);
    function getStakingItemAmount(uint stakingItemId) public view virtual returns (uint);
    function getStakingItemStartTime(uint stakingItemId) public view virtual returns (uint);
    function getStakingItemIsWithdrawnWithoutMinting(uint stakingItemId) public view virtual returns (bool);
    function getStakingItemIsClaimed(uint stakingItemId) public view virtual returns (bool);
}

contract MustachioRascals is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter tokenIds;
    
    uint mintPrice = 150000 ether;
    uint public max_mustachios = 10000;

    uint stakeRequired;
    uint stakeDuration;

    string public PROVENANCE_HASH = "";
    string baseUri = "https://ownly.tk/api/mustachio-rascals/";

    address payable admin = payable(0x672b733C5350034Ccbd265AA7636C3eBDDA2223B);
    address paymentTokenAddress;

    bool public saleIsActive = false;

    constructor() ERC721("Mustachio Rascals", "RASCALS") {}

    function setPaymentTokenAddress(address payable _paymentTokenAddress) public onlyOwner virtual {
        paymentTokenAddress = _paymentTokenAddress;
    }

    function getPaymentTokenAddress() public view virtual returns (address) {
        return paymentTokenAddress;
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

    function reserveMustachios(address[] memory accounts) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            mintNFT(accounts[i]);
        }
    }

    function totalSupply() public view returns (uint) {
        return tokenIds.current();
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

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function getMintPrice() public view returns (uint) {
        return mintPrice;
    }
    
    function setMintPrice(uint _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function stakeMint(address nftStakingAddress, uint stakingItemId) public {
        INFTStaking nftStaking = INFTStaking(nftStakingAddress);

        address stakingItemNftContractAddress = nftStaking.getStakingItemNftContractAddress(stakingItemId);
        address stakingItemAccount = nftStaking.getStakingItemAccount(stakingItemId);
        uint stakingItemAmount = nftStaking.getStakingItemAmount(stakingItemId);
        uint stakingItemStartTime = nftStaking.getStakingItemStartTime(stakingItemId);
        bool stakingItemIsWithdrawnWithoutMinting = nftStaking.getStakingItemIsWithdrawnWithoutMinting(stakingItemId);
        bool stakingItemIsClaimed = nftStaking.getStakingItemIsClaimed(stakingItemId);

        require(stakingItemNftContractAddress == address(this), "Staking item is not valid for this collection.");
        require(stakingItemAccount == msg.sender, "Your account is not valid for this staking item.");
        require(stakingItemAmount >= stakeRequired, "Staking amount is invalid.");
        require(block.timestamp - stakingItemStartTime >= stakeDuration, "Staking duration is not finish yet.");
        require(!stakingItemIsWithdrawnWithoutMinting, "Staking item is withdrawn before claiming the NFT.");
        require(!stakingItemIsClaimed, "Staking item is already claimed.");

        nftStaking.setStakingItemAsClaimed(stakingItemId);

        mintNFT(msg.sender);
    }

    function purchaseMint() public virtual payable {
        require(saleIsActive, "Sale must be active to mint your Mustachio.");
        require(tokenIds.current() + 1 <= max_mustachios, "Purchase would exceed max supply of Mustachios.");

        IERC20 paymentTokenContract = IERC20(paymentTokenAddress);
        uint allowance = paymentTokenContract.allowance(msg.sender, address(this));

        require(allowance >= mintPrice, "Please approve the NFT contract with the right payment amount.");

        paymentTokenContract.transferFrom(msg.sender, address(this), mintPrice);

        mintNFT(msg.sender);
    }

    function mintNFT(address _address) internal {
        tokenIds.increment();
        uint tokenId = tokenIds.current();
        _mint(_address, tokenId);
    }

    function withdraw() public onlyOwner {
        admin.transfer(address(this).balance);
    }

    function withdrawPaymentToken() public onlyOwner {
        IERC20 paymentTokenContract = IERC20(paymentTokenAddress);
        uint allowance = paymentTokenContract.allowance(msg.sender, address(this));

        require(allowance >= mintPrice, "Please approve the NFT contract with the right payment amount.");

        paymentTokenContract.transferFrom(msg.sender, address(this), mintPrice);
        admin.transfer(address(this).balance);
    }
}