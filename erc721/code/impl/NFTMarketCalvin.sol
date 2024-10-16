// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../INFTMarket.sol";
import "../IERC20Token.sol";
import "../IERC1363Receiver.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFTMarketCalvin is INFTMarket, IERC1363Receiver{

    //mapping  nft(tokenId)  to  token(token address) to price(how much) ( nft priced by token(what kind of token))
    mapping (uint => uint) public tokensPrice ;

    address public tokenAddress;

    address public nftAddress;



    constructor(address _tokenAddress, address _nftAddress){
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
    }


    //list: seller 
    function list(uint nftTokenId, uint value) external {
        //sender must own or approved tokenId
        ERC721URIStorage nftAddress721 = ERC721URIStorage(nftAddress);
        require(nftAddress721.ownerOf(nftTokenId) != address(0) ,"tokenId must exist");
        require(msg.sender == nftAddress721.ownerOf(nftTokenId) 
            || nftAddress721.isApprovedForAll(nftAddress721.ownerOf(nftTokenId), address(this)) 
            || msg.sender == nftAddress721.getApproved(nftTokenId),"Only owner or approved can call this function");
        //list
        tokensPrice[nftTokenId]= value;
    }

    function buyNFT(uint nftTokenId) external {
        ERC721URIStorage nftAddress721 = ERC721URIStorage(nftAddress);
        require(nftAddress721.ownerOf(nftTokenId) != address(0) ,"tokenId must exist");
        require(tokensPrice[nftTokenId] != 0,"tokenId must on list");
        address nftOwner = nftAddress721.ownerOf(nftTokenId);
        //transfer nft to buyer
        nftAddress721.transferFrom(nftOwner, msg.sender, nftTokenId);
        //transfer token to seller
        IERC20Token(tokenAddress).transferFrom(msg.sender, nftOwner, tokensPrice[nftTokenId]);
        //unlist tokenId
        tokensPrice[nftTokenId] = 0;
    }


    
    function tokensReceived(address operator, address from, uint256 value, bytes calldata data) external{
        require(msg.sender == tokenAddress,"Only operator can call this function");
        (uint tokenId) = abi.decode(data,(uint));

        ERC721URIStorage nftAddress721 = ERC721URIStorage(nftAddress);
        IERC20Token erc20Token = IERC20Token(msg.sender);
        require(nftAddress721.ownerOf(tokenId) != address(0) ,"tokenId must exist");
        require(tokensPrice[tokenId] == value,"paied tokens must equal to list price");
        address nftOwner = nftAddress721.ownerOf(tokenId);
        //transfer nft to buyer
        nftAddress721.transferFrom(nftOwner, operator, tokenId);
        //transfer token to seller
        erc20Token.transfer(nftOwner, tokensPrice[tokenId]);
        //unlist tokenId
        tokensPrice[tokenId] = 0;
    }


}
