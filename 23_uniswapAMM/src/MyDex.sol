//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./IDex.sol";

contract MyDex is IDex{


    //fork mainnet
    //deploy rnt
    //mint rnt to admin
    //deal buyer rnt
    //admin create pair and LP
    //buyer sellETH
    //check
    //buyer buyETH
    //check
    //admin


    function sellETH(address buyToken,uint256 minBuyAmount) external payable;


    function buyETH(address sellToken,uint256 sellAmount,uint256 minBuyAmount) external;


}