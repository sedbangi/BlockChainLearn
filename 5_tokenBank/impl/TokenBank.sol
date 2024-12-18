// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20Bank.sol";
import "../IERC20Token.sol";

contract TokenBank is IERC20Bank {

    //admin ( contract deployer)
    address payable public owner;

    //user own multi tokens  1. address :user address  2.address:token address 3. uint:token balance
    mapping (address => mapping (address => uint)) public balances;

    constructor(){
        owner = payable (msg.sender);
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
    function withdrawToOwner(IERC20Token tokenAddress) public {
        //withdraw current address's all tokens to current address's owner
        require(msg.sender == owner,"Not Owner!");
        tokenAddress.transfer(owner, tokenAddress.balanceOf(address(this)));
    }

}
