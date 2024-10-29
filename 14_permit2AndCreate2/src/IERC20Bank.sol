// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20Token.sol";


interface IERC20Bank {


    // deposit erc20 token
    function deposit(IERC20Token tokenAddress, uint value) external;

    // token
    function withdraw(IERC20Token tokenAddress, uint value) external;

}