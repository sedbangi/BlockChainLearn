// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20Token.sol";

interface IERC20BankV2 {

    // who (userAddress) save how much ( value ) what( tokenAddress ) 
    function tokensReceived(address userAddress, uint value) external ;
    
}