// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



interface IERC20Token {

    function balanceOf(address) external  view returns (uint256 balance);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function allowance(address, address) external view returns (uint256);

}