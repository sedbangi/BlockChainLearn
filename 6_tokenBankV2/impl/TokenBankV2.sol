// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenBank.sol";
import "../IERC20BankV2.sol";

contract TokenBankV2 is TokenBank, IERC20BankV2{

    address public tokenAddress;

    constructor(address _tokenAddress){
        tokenAddress = _tokenAddress;
    }

    //execute when receive tokens (who (userAddress) save how much ( value ) what( tokenAddress ) )
    function tokensReceived(address userAddress, uint value) external {
        require(msg.sender == tokenAddress, "sender address must equal to token address");
        balances[userAddress][tokenAddress] += value;
    }

}
