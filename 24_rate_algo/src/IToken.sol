//SPDX-License-Identifier:
pragma solidity ^0.8.23;



/**
 * @title KK Token
 */
interface IToken is IERC20 {
    function mint(address to, uint256 amount) external;
}