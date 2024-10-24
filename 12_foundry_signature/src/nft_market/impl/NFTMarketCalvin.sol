// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../INFTMarket.sol";
import "../IERC20Token.sol";
import "../IERC1363Receiver.sol";
import "./NFTCalvin.sol";
import "../../../lib/forge-std/src/console.sol";

import "../../../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import  "../IEIP2612.sol";


contract NFTMarketCalvin is INFTMarket, IERC1363Receiver {

    //mapping  nft(tokenId)  to  token(token address) to price(how much) ( nft priced by token(what kind of token))
    mapping(uint => uint) public tokensPrice;

    address public tokenAddress;

    address public nftAddress;

    //erc2612
    bytes32 constant WHITE_LIST_TYPEHASH = keccak256("WhiteList(address[] whiteList)");

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 DOMAIN_SEPARATOR;

    event listEvent(uint tokenId, uint price);
    event buyEvent(address buyerAddress, uint tokenId, uint price);

    error BuyOwnNFT(uint tokenId);
    error PriceNotEqual(uint tokenId, uint price);


    constructor(address _tokenAddress, address _nftAddress){
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;

        DOMAIN_SEPARATOR = hashStruct(
            IEIP2612.EIP712Domain({
                name: "NFTMarketCalvin",
                version: "1",
                chainId: block.chainid,
                verifyingContract: address(this)
            })
        );
    }

    function getTokenPrice(uint tokenId) public view returns (uint) {
        return tokensPrice[tokenId];
    }

    //list: seller
    function list(uint nftTokenId, uint value) external {
        //sender must own or approved tokenId
        ERC721URIStorage nftAddress721 = ERC721URIStorage(nftAddress);
        nftAddress721.ownerOf(nftTokenId);
        require(nftAddress721.ownerOf(nftTokenId) != address(0), "tokenId must exist");
        require(msg.sender == nftAddress721.ownerOf(nftTokenId)
        || nftAddress721.isApprovedForAll(nftAddress721.ownerOf(nftTokenId), address(this))
        || msg.sender == nftAddress721.getApproved(nftTokenId), "Only owner or approved can call this function");
        //list
        tokensPrice[nftTokenId] = value;

        emit listEvent(nftTokenId, value);
    }

    function buyNFT(uint nftTokenId) public {
        ERC721URIStorage nftAddress721 = ERC721URIStorage(nftAddress);
        require(nftAddress721.ownerOf(nftTokenId) != address(0), "tokenId must exist");
        require(tokensPrice[nftTokenId] != 0, "tokenId must on list");
        address nftOwner = nftAddress721.ownerOf(nftTokenId);
//        require(msg.sender != nftOwner, BuyOwnNFT(nftTokenId));
        uint tokenPrice = tokensPrice[nftTokenId];
        //transfer nft to buyer
        nftAddress721.transferFrom(nftOwner, msg.sender, nftTokenId);
        //transfer token to seller
        IERC20Token(tokenAddress).transferFrom(msg.sender, nftOwner, tokenPrice);
        //unlist tokenId
        tokensPrice[nftTokenId] = 0;

        emit buyEvent(msg.sender, nftTokenId, tokenPrice);
    }


    function tokensReceived(address operator, address from, uint256 value, bytes calldata data) external {
        require(msg.sender == tokenAddress, "Only Support token: tokenAddress ");
        (uint tokenId) = abi.decode(data, (uint));

        ERC721URIStorage nftAddress721 = ERC721URIStorage(nftAddress);
        IERC20Token erc20Token = IERC20Token(tokenAddress);
        require(nftAddress721.ownerOf(tokenId) != address(0), "tokenId must exist");
//        require(tokensPrice[tokenId] == value, PriceNotEqual(tokenId,value));
        address nftOwner = nftAddress721.ownerOf(tokenId);
        //transfer nft to buyer
        nftAddress721.transferFrom(nftOwner, operator, tokenId);
        //transfer token to seller
        erc20Token.transfer(nftOwner, tokensPrice[tokenId]);
        //unlist tokenId
        tokensPrice[tokenId] = 0;
    }

    //erc2612
    function permitBuy(uint nftTokenId, IEIP2612.WhiteList memory whiteList, uint8 v, bytes32 r, bytes32 s) public {
        //verify
        require(verify(whiteList,v,r,s),"invalid white list");
        //check in list
        for(uint i = 0; i<whiteList.whiteList.length;i++){
            if(whiteList.whiteList[0] == msg.sender){
                //allow to buyNFT
                buyNFT(nftTokenId);
                return;
            }
        }
        revert("you are not in white list");
    }

    function hashStruct(
        IEIP2612.EIP712Domain memory eip712Domain
    ) internal pure returns (bytes32) {
        return
            keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(eip712Domain.name)),
                keccak256(bytes(eip712Domain.version)),
                eip712Domain.chainId,
                eip712Domain.verifyingContract
            )
        );
    }

    function hashStruct(IEIP2612.WhiteList memory whiteList) internal pure returns (bytes32) {
        return
            keccak256(
            abi.encode(
                WHITE_LIST_TYPEHASH,
                whiteList.whiteList
            )
        );
    }

    function verify(
        IEIP2612.WhiteList memory whiteList,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool) {
        // Note: we need to use `encodePacked` here instead of `encode`.
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct(whiteList))
        );
        //ensure whiteList came from tokenAddress' project launcher
        return ecrecover(digest, v, r, s) == NFTCalvin(nftAddress).owner();
    }


}
