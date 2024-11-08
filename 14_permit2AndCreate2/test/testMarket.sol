// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/openzeppelin-foundry-upgrades/src/Upgrades.sol";
import "../src/NFTMarketUpgrade/MarketV2.sol";
import "../src/NFTMarketUpgrade/NFT.sol";
import "../src/NFTMarketUpgrade/Token.sol";
import "../src/NFTMarketUpgrade/Market.sol";
import {Test, console} from "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract testMarket is Test{

    address tokenAddress;
    address nftAddress;
//    address marketAddress;
//    address marketV2Address;
    address proxyAddress;

    Token token;
    NFT nft;
    Market market;
    MarketV2 marketV2;

    address admin = vm.randomAddress();
    address buyer = vm.randomAddress();
    uint256 sellerPk = vm.randomUint();
    address seller = vm.addr(sellerPk);


    uint public tokenId;
    uint price = 100;

    bytes32 private constant LIST_INFO_TYPE_HASH = keccak256(
        "ListInfo(uint256 tokenId,uint256 price,address seller)"
    );

    bytes32 private constant TYPE_HASH =
    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function setUp() public {

        //deploy token
        token = new Token("calvin", "calvin");
        tokenAddress = address(token);
        //deploy nft
        nft = new NFT("calvin", "calvin");
        nftAddress = address(nft);
        //deploy market
        vm.startPrank(admin);
        bytes memory initData = abi.encodeWithSelector(Market.init.selector, tokenAddress, nftAddress);
        proxyAddress = Upgrades.deployTransparentProxy("Market.sol", admin, initData);
        market = Market(proxyAddress);
        vm.stopPrank();

        vm.startPrank(seller);
        //seller mint nft
        tokenId = nft.mint("tokenURI");
        vm.stopPrank();

    }

    function test_listAndBuy() public {

        //seller approve market and list
        vm.startPrank(seller);
        nft.setApprovalForAll(proxyAddress, true);
        market.list(tokenId, price);
        vm.stopPrank();

        //deal buyer token and approve market and buyer buy
        deal(tokenAddress, buyer, price);
        vm.startPrank(buyer);
        token.approve(proxyAddress, price);
        market.buyNFT(tokenId);
        vm.stopPrank();

        //balanceOf user 1
        console.log('buyer balance', token.balanceOf(buyer));
        //balanceOf user 2
        console.log('seller balance', token.balanceOf(seller));
        //balanceOf user 3
        console.log('nft belong to', nft.ownerOf(tokenId));

        //check token balance and nft belongs
        assertEq(token.balanceOf(buyer), 0, "buyer pay token");
        assertEq(token.balanceOf(seller), price, "seller receive token");
        assertEq(nft.ownerOf(tokenId), buyer, "nft belong to buyer");
    }

    function test_listAndBuyV2() public {
        // upgrade v1 to v2
        vm.startPrank(admin);
        Upgrades.upgradeProxy(
            proxyAddress,
            "MarketV2.sol",
            abi.encodeWithSelector(MarketV2.init.selector, tokenAddress, nftAddress)
        );
        vm.stopPrank();

        // seller approve the market and sign list
        vm.startPrank(seller);
        nft.setApprovalForAll(proxyAddress,true);
        MarketV2.ListInfo memory listInfo = MarketV2.ListInfo(tokenId,price,seller);
        bytes32 domain = keccak256(abi.encode(TYPE_HASH, keccak256(bytes("calvin")),keccak256(bytes("1")), block.chainid, proxyAddress));
        bytes32 digest = MessageHashUtils.toTypedDataHash(domain,hashStruct(listInfo));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign( sellerPk,digest);
        vm.stopPrank();

        // buyer approve market and buyWithSignature
        vm.startPrank(buyer);
        deal(tokenAddress,buyer,price);
        token.approve(proxyAddress,price);
        MarketV2(proxyAddress).buyWithSignature(listInfo,v,r,s);
        vm.stopPrank();


        console.log('buyer balance', token.balanceOf(buyer));
        console.log('seller balance', token.balanceOf(seller));
        console.log('nft belong to', nft.ownerOf(tokenId));

        //check token balance and nft belongs
        assertEq(token.balanceOf(buyer), 0, "buyer pay token");
        assertEq(token.balanceOf(seller), price, "seller receive token");
        assertEq(nft.ownerOf(tokenId), buyer, "nft belong to buyer");

    }


    function hashStruct(MarketV2.ListInfo memory listInfo) internal pure returns (bytes32) {
        return
            keccak256(
            abi.encode(
                LIST_INFO_TYPE_HASH,
                listInfo.tokenId,
                listInfo.price,
                listInfo.seller
            )
        );
    }


}