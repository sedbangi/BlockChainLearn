// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "./RNT.sol";

contract IDO {


    mapping(address => PresaleRule) public tokenPresaleRule;

    struct PresaleRule {
        address tokenAddress;
        address admin;
        uint tokenAmount;
        uint targetETHAmount;
        uint maxETHAmount;
        uint deadline;
    }
    //first address: tokenAddress second address: userAddress uint: balance
    mapping(address => mapping(address => uint)) public balances;
    // token's current ETHAmount
    mapping(address => uint) public raisedETHAmount;

    modifier OnlyActive (address tokenAddress, uint amount){
        PresaleRule memory presaleRule = tokenPresaleRule[tokenAddress];
        uint _currentETHAmount = raisedETHAmount[tokenAddress];
        require(block.timestamp < presaleRule.deadline,"beyond the deadline");
        require((_currentETHAmount+amount) < presaleRule.maxETHAmount,"have reached max ETHAmount");
        _;
    }

    modifier OnlySuccess (address tokenAddress) {
        PresaleRule memory presaleRule = tokenPresaleRule[tokenAddress];
        uint _currentETHAmount = raisedETHAmount[tokenAddress];
        require(block.timestamp > presaleRule.deadline,"haven't reach deadline");
        require(_currentETHAmount >= presaleRule.targetETHAmount,"haven't raised enough ETH");
        _;
    }
    modifier OnlyFailed (address tokenAddress) {
        PresaleRule memory presaleRule = tokenPresaleRule[tokenAddress];
        uint _currentETHAmount = raisedETHAmount[tokenAddress];
        require(block.timestamp > presaleRule.deadline,"haven't reach deadline");
        require(_currentETHAmount < presaleRule.targetETHAmount,"have raised enough ETH");
        _;
    }

    function publishIDO(PresaleRule memory presaleRule) public {
        //check: IDO should be transferred the specified amount token
        require(ERC20(presaleRule.tokenAddress).balanceOf(address(this)) >= presaleRule.tokenAmount,"IDO should be transferred the specified amount token");
        tokenPresaleRule[presaleRule.tokenAddress] = presaleRule;
    }

    function presale(address tokenAddress) public payable OnlyActive(tokenAddress, msg.value) {
        balances[tokenAddress][msg.sender] += msg.value;
        raisedETHAmount[tokenAddress] += msg.value;
    }

    function claim(address tokenAddress) public OnlySuccess(tokenAddress) {
        PresaleRule memory presaleRule = tokenPresaleRule[tokenAddress];
        uint amount = presaleRule.tokenAmount * balances[tokenAddress][msg.sender] / raisedETHAmount[tokenAddress];

        RNT(tokenAddress).transfer(msg.sender, amount);
        balances[tokenAddress][msg.sender] = 0;
    }

    //for token launcher to withdraw token
    function withdraw(address tokenAddress) public OnlySuccess(tokenAddress) {
        uint raisedAmount = raisedETHAmount[tokenAddress];
        PresaleRule memory presaleRule = tokenPresaleRule[tokenAddress];
        payable(presaleRule.admin).transfer(raisedAmount);
    }

    function refund(address tokenAddress) public OnlyFailed(tokenAddress) {
        payable(msg.sender).transfer(balances[tokenAddress][msg.sender]);
        balances[tokenAddress][msg.sender] = 0;
    }

}
