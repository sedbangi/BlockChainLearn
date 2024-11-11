//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract Bank {
    address payable public owner;
    uint256 public depositLimit;
    mapping(address => uint256) public balances;

    constructor(uint256 _depositLimit) {
        owner = payable(msg.sender);
        depositLimit = _depositLimit;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function setDepositLimit(uint _depositLimit) public {
        require(msg.sender == owner);
        depositLimit = _depositLimit;
    }

    function checkUpkeep(bytes calldata checkData) external view returns (bool upkeepNeeded, bytes memory performData){
        return (address(this).balance >= depositLimit, "");
    }

    function performUpkeep(bytes calldata performData) external {
        require(address(this).balance >= depositLimit,"Deposit limit not reached");

        uint256 halfBalance = address(this).balance / 2;
        owner.transfer(halfBalance);
    }

    function withdrawAllToOwner() external {
        require(msg.sender == owner, "Only owner can withdraw");
        owner.transfer(address(this).balance);
    }
}