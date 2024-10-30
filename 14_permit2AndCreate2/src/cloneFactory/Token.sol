// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    address public owner;
    bool public initialized;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        owner = msg.sender;
    }

    modifier OnlyOwner{
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function mint(address to, uint amount) external OnlyOwner {
        _mint(to, amount);
    }

    function init(string memory name, string memory symbol) public {
        require(!initialized, "have initialized");
        //change _name and _symbol from private to internal
        _name = name;
        _symbol = symbol;
        owner = msg.sender;
        initialized = true;
    }

}