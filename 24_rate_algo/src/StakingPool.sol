//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {IStaking} from "./IStaking.sol";
import "./IToken.sol";
import "../lib/forge-std/src/console.sol";

contract StakingPool is IStaking {

    address public _tokenAddress;

    uint256 public accumulatedRate;
    uint256 public lastBlockNumber;
    uint256 public totalStaked;
    uint256 public constant REWARDS_PER_BLOCK = 10 ether;

    struct UserRewardInfo {
        uint256 staked;
        uint256 unClaimed;
        uint256 accumulatedRate;
        uint256 lastBlockNumber;
    }

    mapping(address => UserRewardInfo) public userRewardInfos;

    constructor(address tokenAddress) {
        _tokenAddress = tokenAddress;
        lastBlockNumber = block.number;
    }

    function stake() payable external {
        require(msg.value != 0, "no eth sent");
        if(totalStaked != 0) {
            console.log("totalStaked",totalStaked);
            accumulatedRate += (block.number - lastBlockNumber) * REWARDS_PER_BLOCK / totalStaked;
            console.log("accumulatedRate",accumulatedRate);
        }

        if (userRewardInfos[msg.sender].staked != 0) {
            userRewardInfos[msg.sender].unClaimed +=
                userRewardInfos[msg.sender].staked * (accumulatedRate - userRewardInfos[msg.sender].accumulatedRate);
        }
        userRewardInfos[msg.sender].staked += msg.value;
        userRewardInfos[msg.sender].lastBlockNumber = block.number;
        userRewardInfos[msg.sender].accumulatedRate = accumulatedRate;

        lastBlockNumber = block.number;
        totalStaked += msg.value;
    }


    function unstake(uint256 amount) external {
        require(userRewardInfos[msg.sender].staked >= amount, "not enough balance");
        accumulatedRate += (block.number - lastBlockNumber) * REWARDS_PER_BLOCK / totalStaked;


        userRewardInfos[msg.sender].unClaimed +=
            userRewardInfos[msg.sender].staked  * (accumulatedRate - userRewardInfos[msg.sender].accumulatedRate);

        userRewardInfos[msg.sender].staked -= amount;
        userRewardInfos[msg.sender].lastBlockNumber = block.number;
        userRewardInfos[msg.sender].accumulatedRate = accumulatedRate;

        lastBlockNumber = block.number;
        totalStaked -= amount;
    }

    function claim() external {
        accumulatedRate += (block.number - lastBlockNumber) * REWARDS_PER_BLOCK / totalStaked;

        if (userRewardInfos[msg.sender].staked != 0) {
            console.log("userRewardInfos[msg.sender].staked",userRewardInfos[msg.sender].staked);
            console.log("accumulatedRate",accumulatedRate);
            console.log("accumulatedRate",userRewardInfos[msg.sender].accumulatedRate);
            userRewardInfos[msg.sender].unClaimed +=
                userRewardInfos[msg.sender].staked  * (accumulatedRate - userRewardInfos[msg.sender].accumulatedRate);
        }
        userRewardInfos[msg.sender].lastBlockNumber = block.number;
        userRewardInfos[msg.sender].accumulatedRate = accumulatedRate;

        lastBlockNumber = block.number;

        IToken(_tokenAddress).mint(msg.sender, userRewardInfos[msg.sender].unClaimed);
        userRewardInfos[msg.sender].unClaimed = 0;
    }

    function balanceOf(address account) external view returns (uint256){
        return userRewardInfos[account].staked;
    }

    function earned(address account) external view returns (uint256){
        require(userRewardInfos[msg.sender].staked != 0, "no staking");
        uint tempAccumulatedRate = accumulatedRate + (block.number - lastBlockNumber) * REWARDS_PER_BLOCK / totalStaked;

        return userRewardInfos[msg.sender].unClaimed +
            userRewardInfos[msg.sender].staked * (tempAccumulatedRate - userRewardInfos[msg.sender].accumulatedRate);
    }

}