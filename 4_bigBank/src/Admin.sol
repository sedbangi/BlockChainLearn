// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBank.sol";


contract Admin{

    address payable public owner;

    constructor(){
        owner = payable (msg.sender);
    }

    // contract address refer to a contract instance! 
    function adminWithdraw(IBank bank) external payable {
        //only owner can withdraw
        require(owner == payable (msg.sender), "only owner can withdraw");
        bank.withdraw();
    }

    receive() external payable { }

    fallback() external payable { }


}