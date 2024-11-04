// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ESRNT is ERC20Permit {

    address public owner;
    address public stakePool;

    constructor(string memory name,string memory symbol) ERC20Permit(name) ERC20(name,symbol){
        owner = msg.sender;
        _mint(msg.sender,100*10**18);
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

    //mint (for stake rewards)
    function mint(address to, uint amount) public OnlyStakePool {

    }


}
