//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RNT is ERC20 {

    constructor(string memory name , string memory symbol) ERC20(name,symbol){

    }

}