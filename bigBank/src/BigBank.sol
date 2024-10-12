// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bank.sol";

contract BigBank is Bank {

    constructor(){}

    modifier limitDeposit() {
        require(msg.value >= 0.001 ether,"deposit amount must be greater than or equal to 0.001 ether");
        _;
    }

    //user call this to desposit
    function deposit() external payable limitDeposit override {
        updateBalancesAndTopThreeUsers();
    }

    //owner can change owner
    function changeOwner(address payable newOwner) external {
        require(msg.sender == owner,"Not Owner");
        owner = newOwner;
    }





}
