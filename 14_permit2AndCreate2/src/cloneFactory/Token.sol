// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20ImplVersion.sol";

contract Token is ERC20ImplVersion {

    address public owner;
    bool public initialized;

    constructor() {
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