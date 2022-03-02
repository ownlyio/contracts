// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTStaking is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter stakingItemIds;

    address stakingTokenAddress;

    struct StakingItem {
        address nftContractAddress;
        address account;
        uint amount;
        uint startTime;
        bool isWithdrawnWithoutMinting;
        bool isClaimed;
    }

    mapping(uint => StakingItem) idToStakingItem;
    mapping(address => bool) collections;

    constructor() {}

    function setStakingTokenAddress(address payable _stakingTokenAddress) public onlyOwner virtual {
        stakingTokenAddress = _stakingTokenAddress;
    }

    function getStakingTokenAddress() public view virtual returns (address) {
        return stakingTokenAddress;
    }

    function stake(address _nftContractAddress, uint amount) public nonReentrant {
        IERC20 stakingTokenContract = IERC20(stakingTokenAddress);
        uint allowance = stakingTokenContract.allowance(msg.sender, address(this));

        require(amount >= allowance, "Please approve the staking contract with the right staking amount.");

        stakingTokenContract.transferFrom(msg.sender, address(this), amount);

        uint stakingItemId = stakingItemIds.current();
        stakingItemIds.increment();

        idToStakingItem[stakingItemId] = StakingItem(
            _nftContractAddress,
            msg.sender,
            amount,
            block.timestamp,
            false,
            false
        );
    }

    function unstake(uint _idToStakingItem) public {
        require(msg.sender == idToStakingItem[_idToStakingItem].account, "Staking item doesn't belong to this account.");
        idToStakingItem[_idToStakingItem].isWithdrawnWithoutMinting = true;

        IERC20 stakingTokenContract = IERC20(stakingTokenAddress);
        stakingTokenContract.transfer(idToStakingItem[_idToStakingItem].account, idToStakingItem[_idToStakingItem].amount);
    }

    function setCollection(address collection, bool status) public onlyOwner {
        collections[collection] = status;
    }

    function setStakingItemAsClaimed(uint _idToStakingItem) public {
        require(collections[msg.sender], "Collection is not in the whitelist.");

        idToStakingItem[_idToStakingItem].isClaimed = true;

        IERC20 stakingTokenContract = IERC20(stakingTokenAddress);
        stakingTokenContract.transfer(idToStakingItem[_idToStakingItem].account, idToStakingItem[_idToStakingItem].amount);
    }

    function getStakingItemNftContractAddress(uint stakingItemId) public view returns (address) {
        return idToStakingItem[stakingItemId].nftContractAddress;
    }

    function getStakingItemAccount(uint stakingItemId) public view returns (address) {
        return idToStakingItem[stakingItemId].account;
    }

    function getStakingItemAmount(uint stakingItemId) public view returns (uint) {
        return idToStakingItem[stakingItemId].amount;
    }

    function getStakingItemStartTime(uint stakingItemId) public view returns (uint) {
        return idToStakingItem[stakingItemId].startTime;
    }

    function getStakingItemIsWithdrawnWithoutMinting(uint stakingItemId) public view returns (bool) {
        return idToStakingItem[stakingItemId].isWithdrawnWithoutMinting;
    }

    function getStakingItemIsClaimed(uint stakingItemId) public view returns (bool) {
        return idToStakingItem[stakingItemId].isClaimed;
    }

    function getStakingItems(address account) public view returns (StakingItem[] memory) {
        uint count = 0;
        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].account == account) {
                count++;
            }
        }

        StakingItem[] memory stakingItems = new StakingItem[](count);

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].account == account) {
                stakingItems[i] = idToStakingItem[i];
            }
        }

        return stakingItems;
    }
}