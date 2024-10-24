// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20Bank.sol";
import "../IERC20Token.sol";
import "../IEIP2612.sol";
import {console} from "../../../lib/forge-std/src/console.sol";

contract TokenBank is IERC20Bank{
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner!");
        _;
    }

    //admin ( contract deployer)
    address payable public owner;

    address public boundTokenAddress;

    //user own multi tokens  1. address :user address  2.address:token address 3. uint:token balance
    mapping(address => mapping(address => uint)) public balances;


    constructor(address _tokenAddress) {
        owner = payable(msg.sender);
        boundTokenAddress = _tokenAddress;
    }

    function changeOwner(address ownerAddress) public onlyOwner {
        owner = payable(ownerAddress);
    }

    function getBalance(address owner_, address tokenAddress_) public returns(uint) {
        return balances[owner_][tokenAddress_];
    }

    // deposit erc20 token
    function deposit(IERC20Token tokenAddress, uint value) external {
        //transfer token to current bank contract address
        tokenAddress.transferFrom(msg.sender, address(this), value);
        balances[msg.sender][address(tokenAddress)] += value;
    }

    // user withdraw tokens from bank to their token contract address
    function withdraw(IERC20Token tokenAddress, uint value) external {
        //withdraw token from bank to token contract
        tokenAddress.transfer(msg.sender, value);
        balances[msg.sender][address(tokenAddress)] -= value;
    }

    // admin can withdraw all tokens
    function withdrawToOwner(IERC20Token tokenAddress) public onlyOwner {
        //withdraw current address's all tokens to current address's owner
        tokenAddress.transfer(owner, tokenAddress.balanceOf(address(this)));
    }

    function permitDeposit(
        IEIP2612.Permit memory permit,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        //execute permit
        IEIP2612(boundTokenAddress).transferWithPermit(permit, v, r, s);
        //update balances
        balances[permit.owner][boundTokenAddress] += permit.value;
    }
}
