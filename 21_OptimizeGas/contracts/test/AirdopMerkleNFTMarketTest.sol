// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/aridropNFTMarket/Token.sol";
import "../src/aridropNFTMarket/NFT.sol";
import "../src/aridropNFTMarket/AirdopMerkleNFTMarket.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../lib/openzeppelin-contracts/contracts/utils/structs/MerkleTree.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";


contract AirdopMerkleNFTMarketTest is Test {


    Token public token;
    NFT public nft;
    AirdopMerkleNFTMarket public market;

    address public tokenAddress;
    address public nftAddress;
    address public marketAddress;

    address public admin = vm.randomAddress();
    uint public price = 100;
    uint public tokenId;

    //merkle rel
    // generated from ../../front/merkleTree/index.ts
    uint256 public buyerPK = 0x48858d18e954e1b62dedf986b1d25f02787cd8dfda3a891e2d66c639a433a79d;
    address public buyer = 0xe1898De73429752070DccEa8514ba1D310821C7C;
    bytes32 public root = bytes32(0x03c02b8774b018fc8d7b371b739ed5de78f4cfe3e8c69283bb679e021794db69);
    bytes32[] public proof = [bytes32(0x00f369b03139ffa987d43ef2453e4b14a9a184bc669bd087e69c25c51332c32f), bytes32(0xbcd38b2035ca1923d0fefc1401c8297a14c0a497c125912152dfd3c279e3386b)];
    bytes[] public calls;


    function setUp() public {
        vm.startPrank(admin);

        //deploy Token
        token = new Token("calvin", "calvin");
        tokenAddress = address(token);

        //deploy NFT
        nft = new NFT("NFTCalvin", "NFTCalvin");
        nftAddress = address(nft);

        //deploy Market
        market = new AirdopMerkleNFTMarket(tokenAddress, nftAddress);
        marketAddress = address(market);

        //calculate merkle root (../../front/merkleTree/index.ts) and set it to Market
        market.setMerkelRoot(root);

        vm.stopPrank();


    }

    function test_discountBuy_success() public {
        vm.startPrank(admin);
        //mint nft and approve and list
        tokenId = nft.mint("tokenURI");
        nft.approve(marketAddress, tokenId);
        market.list(tokenId, price);
        vm.stopPrank();

        vm.startPrank(buyer);
        //buyer sign
        deal(tokenAddress,buyer,price);
        bytes32 digest = MessageHashUtils.toTypedDataHash(
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes ("calvin")),
                    keccak256(bytes ("1")),
                    block.chainid,
                    tokenAddress
                )
            )
            , keccak256(
                abi.encode(
                    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                    buyer,
                    marketAddress,
                    price,
                    token.nonces(buyer),
                    block.timestamp + 60 * 60 * 24
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyerPK, digest);
        //do multiCall("tokenURI");

        calls.push(
            abi.encodeWithSelector(
                AirdopMerkleNFTMarket.permitPrePay.selector,
                buyer,
                marketAddress,
                price,
                block.timestamp + 60 * 60 * 24,
                v,
                r,
                s
            )
        );
        calls.push(
            abi.encodeWithSelector(
                AirdopMerkleNFTMarket.claimNFT.selector,
                tokenId,
                proof
            )
        );
        market.multicall(calls);

        console.log("buyer balance:", token.balanceOf(buyer));
        console.log("seller(admin) balance:", token.balanceOf(admin));
        console.log("nft belong to:", nft.ownerOf(tokenId));

        assertEq(token.balanceOf(buyer), price / 2, "buyer pay half of the price");
        assertEq(token.balanceOf(admin), price / 2, "admin receive half of the price");
        assertEq(nft.ownerOf(tokenId), buyer, "nft transferred to buyer");

        vm.stopPrank();
    }


}
