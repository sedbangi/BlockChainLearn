// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../INFTMarket.sol";
import "../IERC20Token.sol";
import "../IERC1363Receiver.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFTMarketCalvin is INFTMarket, IERC1363Receiver{

    //mapping  nft(tokenId)  to  token(token address) to price(how much) ( nft priced by token(what kind of token))
    mapping (uint => mapping (address => uint)) public tokensPrice ;

    constructor(){}


    //user list nft (nft address) token(tokenId) with price (value)
    function list(address nftAddress, uint nftTokenId, uint value, address tokenAddress) external {
        //sender must own or approved tokenId
        ERC721URIStorage nftCalvin = ERC721URIStorage(nftAddress);
        require(nftCalvin.ownerOf(nftTokenId) != address(0) ,"tokenId must exist");
        require(msg.sender == nftCalvin.ownerOf(nftTokenId) 
            || nftCalvin.isApprovedForAll(nftCalvin.ownerOf(nftTokenId), address(this)) 
            || msg.sender == nftCalvin.getApproved(nftTokenId),"Only owner or approved can call this function");
        //list
        tokensPrice[nftTokenId][tokenAddress] = value;
    }

    //user but NFT(nft nftAddress) token(tokenId) with its price
    function buyNFT(address nftAddress, uint nftTokenId, address tokenAddress) external {
        ERC721URIStorage nftCalvin = ERC721URIStorage(nftAddress);
        IERC20Token erc20Token = IERC20Token(tokenAddress);
        require(nftCalvin.ownerOf(nftTokenId) != address(0) ,"tokenId must exist");
        require(tokensPrice[nftTokenId][tokenAddress] != 0,"tokenId must on list");
        address nftOwner = nftCalvin.ownerOf(nftTokenId);
        //transfer nft to buyer
        nftCalvin.transferFrom(nftOwner, msg.sender, nftTokenId);
        //transfer token to seller
        erc20Token.transferFrom(msg.sender, nftOwner, tokensPrice[nftTokenId][tokenAddress]);
        //unlist tokenId
        tokensPrice[nftTokenId][tokenAddress] = 0;
    }

    // who (buyer) offer how much ( value ) buy what( tokenId )
    function tokensReceived(address buyerAddress, uint value, address nftAddress, uint tokenId) external {

    }
    //data (uint tokenId,address buyerAddress,address nftAddress) this market allow all kinds of tokens and nfts
    function tokensReceived(address operator, address from, uint256 value, bytes calldata data) external{
        require(msg.sender == operator,"Only operator can call this function");
        //this market allow all kinds of tokens and nfts(so user need to specify this 3 parameters)
        (uint tokenId,address buyerAddress, address nftAddress) = abi.decode(data,(uint,address,address));

        ERC721URIStorage nftCalvin = ERC721URIStorage(nftAddress);
        IERC20Token erc20Token = IERC20Token(msg.sender);
        require(nftCalvin.ownerOf(tokenId) != address(0) ,"tokenId must exist");
        require(tokensPrice[tokenId][msg.sender] == value,"paied tokens must equal to list price");
        address nftOwner = nftCalvin.ownerOf(tokenId);
        //transfer nft to buyer
        nftCalvin.transferFrom(from, buyerAddress, tokenId);
        //transfer token to seller
        erc20Token.transfer(nftOwner, tokensPrice[tokenId][msg.sender]);
        //unlist tokenId
        tokensPrice[tokenId][msg.sender] = 0;
    }


}
