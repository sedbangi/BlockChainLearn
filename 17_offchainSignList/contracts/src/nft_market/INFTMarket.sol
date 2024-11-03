// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20Token.sol";

interface INFTMarket {
    //user list nft token(tokenId) with price (value)
    function list(uint nftTokenId, uint value) external ;

    //user but NFT token(tokenId) 
    function buyNFT(uint nftTokenId) external ;

    //


}