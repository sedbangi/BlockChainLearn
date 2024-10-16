// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20Token.sol";

interface INFTMarket {
    //user list nft token(tokenId) with price (value)
    function list(address nftAddress, uint nftTokenId, uint value, address tokenAddress) external ;

    //user but NFT token(tokenId) 
    function buyNFT(address nftAddress, uint nftTokenId, address tokenAddress) external ;


}