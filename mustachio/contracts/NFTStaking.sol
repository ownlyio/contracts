// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract NFTStaking is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter stakingItemIds;

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
    mapping(address => uint) collectionMaxStaking;

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    function version() pure public virtual returns (string memory) {
        return "v1";
    }

    function getStakingItemIdHeight() public view virtual returns (uint) {
        return stakingItemIds.current();
    }

    function setFirstStakingItemAsEmpty() public onlyOwner virtual {
        uint stakingItemId = stakingItemIds.current();
        stakingItemIds.increment();

        idToStakingItem[stakingItemId] = StakingItem(
            address(0),
            address(0),
            0,
            0,
            false,
            false
        );
    }

    function setStakingTokenAddress(address payable _stakingTokenAddress) public onlyOwner virtual {
        stakingTokenAddress = _stakingTokenAddress;
    }

    function getStakingTokenAddress() public view virtual returns (address) {
        return stakingTokenAddress;
    }

    function stake(address _nftContractAddress, uint amount) public virtual {
        uint currentStakingItemId = getCurrentStakingItemId(msg.sender, _nftContractAddress);
        require(currentStakingItemId == 0, "You have a current staking item. You can only stake once for every address.");

        uint mintedStakingItemId = getMintedStakingItemId(msg.sender, _nftContractAddress);
        require(mintedStakingItemId == 0, "You have already staked and minted with this address. Use another account to stake a new one.");

        IERC20Upgradeable stakingTokenContract = IERC20Upgradeable(stakingTokenAddress);
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

    function unstake(uint _idToStakingItem) public virtual {
        require(msg.sender == idToStakingItem[_idToStakingItem].account, "Staking item doesn't belong to this account.");
        require(idToStakingItem[_idToStakingItem].isWithdrawnWithoutMinting == false, "");

        idToStakingItem[_idToStakingItem].isWithdrawnWithoutMinting = true;

        IERC20Upgradeable stakingTokenContract = IERC20Upgradeable(stakingTokenAddress);
        stakingTokenContract.transfer(idToStakingItem[_idToStakingItem].account, idToStakingItem[_idToStakingItem].amount);
    }

    function setCollectionMaxStaking(address nftContractAddress, uint quantity) public onlyOwner virtual {
        collectionMaxStaking[nftContractAddress] = quantity;
    }

    function setStakingItemAsClaimed(uint _idToStakingItem) public virtual {
        require(collectionMaxStaking[msg.sender] > 0, "Collection is not in the whitelist.");

        idToStakingItem[_idToStakingItem].isClaimed = true;

        IERC20Upgradeable stakingTokenContract = IERC20Upgradeable(stakingTokenAddress);
        stakingTokenContract.transfer(idToStakingItem[_idToStakingItem].account, idToStakingItem[_idToStakingItem].amount);
    }

    function getStakingItemNftContractAddress(uint stakingItemId) public view virtual returns (address) {
        return idToStakingItem[stakingItemId].nftContractAddress;
    }

    function getStakingItem(uint stakingItemId) public view virtual returns (StakingItem memory) {
        return idToStakingItem[stakingItemId];
    }

    function getStakingItemAccount(uint stakingItemId) public view virtual returns (address) {
        return idToStakingItem[stakingItemId].account;
    }

    function getStakingItemAmount(uint stakingItemId) public view virtual returns (uint) {
        return idToStakingItem[stakingItemId].amount;
    }

    function getStakingItemStartTime(uint stakingItemId) public view virtual returns (uint) {
        return idToStakingItem[stakingItemId].startTime;
    }

    function getStakingItemIsWithdrawnWithoutMinting(uint stakingItemId) public view virtual returns (bool) {
        return idToStakingItem[stakingItemId].isWithdrawnWithoutMinting;
    }

    function getStakingItemIsClaimed(uint stakingItemId) public view virtual returns (bool) {
        return idToStakingItem[stakingItemId].isClaimed;
    }

    function getCurrentStakingItemId(address account, address nftContractAddress) public view virtual returns (uint) {
        uint currentStakingItemId;

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].account == account && idToStakingItem[i].nftContractAddress == nftContractAddress && !idToStakingItem[i].isWithdrawnWithoutMinting && !idToStakingItem[i].isClaimed) {
                currentStakingItemId = i;
            }
        }

        return currentStakingItemId;
    }

    function getMintedStakingItemId(address account, address nftContractAddress) public view virtual returns (uint) {
        uint mintedStakingItemId;

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].account == account && idToStakingItem[i].nftContractAddress == nftContractAddress && idToStakingItem[i].isClaimed) {
                mintedStakingItemId = i;
            }
        }

        return mintedStakingItemId;
    }

    function getStakingItemId(address account, address nftContractAddress) public view virtual returns (uint) {
        uint currentStakingItemId;
        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].account == account && idToStakingItem[i].nftContractAddress == nftContractAddress && !idToStakingItem[i].isWithdrawnWithoutMinting && !idToStakingItem[i].isClaimed) {
                currentStakingItemId = i;
            }
        }

        return currentStakingItemId;
    }

    function totalDeposits(address nftContractAddress) public view virtual returns (uint) {
        uint _totalDeposits = 0;

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].nftContractAddress == nftContractAddress && !idToStakingItem[i].isWithdrawnWithoutMinting && !idToStakingItem[i].isClaimed) {
                _totalDeposits += idToStakingItem[i].amount;
            }
        }

        return _totalDeposits;
    }

    function totalStakes(address nftContractAddress) public view virtual returns (uint) {
        uint _totalStakes = 0;

        for(uint i = 0; i < stakingItemIds.current(); i++) {
            if(idToStakingItem[i].nftContractAddress == nftContractAddress && !idToStakingItem[i].isWithdrawnWithoutMinting) {
                _totalStakes++;
            }
        }

        return _totalStakes;
    }

    function remainingRewards(address nftContractAddress) public view virtual returns (uint) {
        return collectionMaxStaking[nftContractAddress] - totalStakes(nftContractAddress);
    }
}