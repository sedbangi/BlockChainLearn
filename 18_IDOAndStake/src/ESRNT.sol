// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {RNT} from "./RNT.sol";
import "../lib/forge-std/src/console.sol";
contract ESRNT is ERC20 {

    address public owner;
    address public stakePool;
    address public rntAddress;

    LockInfo[] public lockInfos;

    struct LockInfo {
        address user;
        uint amount;
        uint lockTime;
        bool burned;
    }

    constructor(string memory name, string memory symbol, address _rntAddress) ERC20(name, symbol){
        owner = msg.sender;
        rntAddress = _rntAddress;
    }

    modifier OnlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }
    modifier OnlyStakePool(){
        require(msg.sender == stakePool, "Only StakePool");
        _;
    }

    function setStakePool(address stakePoolAddress) public OnlyOwner {
        stakePool = stakePoolAddress;
    }

    //mint (for stake)
    function mint(address to, uint amount) public OnlyStakePool {
        _mint(to, amount);
        lockInfos.push(LockInfo({
            user: to,
            amount: amount,
            lockTime: block.timestamp,
            burned: false
        }));
    }

    //burn (for users)
    function burn(uint index) public {
        require(balanceOf(msg.sender) > 0, "you must own esRNT");
        LockInfo storage lockInfo = lockInfos[index];
        require(lockInfo.user == msg.sender, "not your esRNT");
        require(!lockInfo.burned, "invalid index");

        uint lockedTime = block.timestamp - lockInfo.lockTime;
        console.log(lockedTime);
        console.log(lockInfo.amount);
        console.log(lockInfo.amount * lockedTime/ 30 days);
        uint lockedRNT = lockedTime >= 30 days ? lockInfo.amount : lockInfo.amount * lockedTime/ 30 days;
        //transfer RNT
        RNT(rntAddress).transfer(msg.sender, lockedRNT);
        //burn RNT
        if (lockedTime < 30 days) {
            RNT(rntAddress).burn(lockInfo.amount - lockedRNT);
        }
        //burn all esRNT
        _burn(msg.sender,lockInfo.amount);

        //invalid lockInfo
        lockInfo.burned = true;

    }
}
