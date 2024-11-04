// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RNT is ERC20Permit {

    address public owner;

    constructor(string memory name,string memory symbol) ERC20Permit(name) ERC20(name,symbol){
        owner = msg.sender;
        _mint(msg.sender,100*10**18);
    }


    function burn(uint amount) public {
        _burn(msg.sender, amount);
    }

}
