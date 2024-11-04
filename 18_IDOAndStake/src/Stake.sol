// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./RNT.sol";
import "./ESRNT.sol";

contract Stake {

    address public RNTAddress;
    address public esRNTAddress;


    mapping(address=>StakeInfo) public stakeInfos;

    struct StakeInfo{
        uint staked;
        uint unclaimed;
        uint lastUpdateTime;
    }

    constructor(address _RNTAddress, address _esRNTAddress){
        RNTAddress = _RNTAddress;
        esRNTAddress = _esRNTAddress;
    }

    //stake
    function stake(uint amount) public {
        //transfer RNT
        RNT(RNTAddress).transferFrom(msg.sender, address (this), amount);
        //update stake
        StakeInfo storage stakeInfo = stakeInfos[msg.sender];
        stakeInfo.unclaimed += stakeInfo.staked * (block.timestamp - stakeInfo.lastUpdateTime)/ 1 days;
        stakeInfo.staked += amount;
        stakeInfo.lastUpdateTime = block.timestamp;
    }

    //unStake
    function unStake(uint amount) public {
        //transfer RNT
        RNT(RNTAddress).transfer(msg.sender, amount);
        //update stake
        StakeInfo storage stakeInfo = stakeInfos[msg.sender];
        stakeInfo.unclaimed += stakeInfo.staked * (block.timestamp - stakeInfo.lastUpdateTime)/ 1 days;
        stakeInfo.staked -= amount;
        stakeInfo.lastUpdateTime = block.timestamp;
    }
    
    //claim
    function claim() public {
        StakeInfo storage stakeInfo = stakeInfos[msg.sender];
        uint unclaimed = stakeInfo.staked * (block.timestamp - stakeInfo.lastUpdateTime)/1 days;
        ESRNT(esRNTAddress).mint(msg.sender,unclaimed);
        RNT(RNTAddress).transfer(esRNTAddress, unclaimed);
        stakeInfo.unclaimed = 0;
        stakeInfo.lastUpdateTime = block.timestamp;
    }

}