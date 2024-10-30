// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Token} from "./Token.sol";


contract Erc20Factory {

    //this states are Inscription's Attributes. so put them there instead of erc20
    mapping(address => TokenAttribute) public tokens;

    struct TokenAttribute {
        uint perMint;
        uint totalSupply;
    }

    event TokenCreated(address newTokenAddress);
    event TokenMinted(address to, address tokenAddress, uint amount);

    //any user can call this to deploy token
    function deployInscription(string memory symbol, uint totalSupply, uint perMint) public returns (address){
        address token = address (new Token(symbol, symbol));
        tokens[token] = TokenAttribute({
            perMint: perMint,
            totalSupply: totalSupply
        });

        emit TokenCreated(token);
        return token;
    }

    //any user can only call this func to mint token.
    function mintInscription(address tokenAddr) public {
        TokenAttribute memory tokenAttribute = tokens[tokenAddr];
        require(tokenAttribute.totalSupply > 0, "this tokenAddr not exist or have no totalSupply");

        Token token = Token(tokenAddr);
        require(token.totalSupply() + tokenAttribute.perMint < tokenAttribute.totalSupply, "have reached to totalSupply");
        Token(tokenAddr).mint(msg.sender, tokenAttribute.perMint);

        emit TokenMinted(msg.sender, tokenAddr, tokenAttribute.perMint);
    }
}
