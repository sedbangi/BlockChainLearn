//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./IToken.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Token is IToken ,Ownable, ERC20 {

    address public stakingPool;

    constructor(string memory name, string memory symbol) Ownable(msg.sender) ERC20 (name,symbol) {}

    function setStakingPool(address stakingPoolAddress) external onlyOwner  {
        stakingPool = stakingPoolAddress;
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == stakingPool ,"only stakingPool can mint");
        _mint(to,amount);
    }


}