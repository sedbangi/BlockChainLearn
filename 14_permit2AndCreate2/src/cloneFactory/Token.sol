// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC20Upgradeable} from "../../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";


contract Token is ERC20Upgradeable {

    address public owner;
    bool public initialized;

    modifier OnlyOwner{
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function mint(address to, uint amount) external OnlyOwner {
        _mint(to, amount);
    }

    function init(string memory name, string memory symbol) public initializer {
        __ERC20_init(name,symbol);
        owner = msg.sender;
    }

}