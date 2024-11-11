//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC20Permit} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20Permit {

    constructor(string memory _name,string memory _symbol) ERC20Permit(_name) ERC20(_name,_symbol)  {}

}