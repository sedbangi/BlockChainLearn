// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import "../src/nft_market/impl/CalvinERC20.sol";
import "../src/nft_market/impl/NFTCalvin.sol";
import "../src/nft_market/impl/NFTMarketCalvin.sol";

contract OfflineBuyTest is Test {
    address tokenAddress;
    address nftAddress;
    address marketAddress;

    CalvinERC20 token;
    NFTCalvin nft;
    NFTMarketCalvin market;

    uint public buyerPK = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint public sellerPK = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint public nftProjectLauncherPK = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
    address public buyer = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public seller = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    address public nftProjectLauncher = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
    uint public price = 200;
    uint public ethPrice = 1 ether;
    uint public tokenId;

    address [] public _whiteList = [buyer];

    function setUp() public {
        token = new CalvinERC20();
        tokenAddress = address(token);

        nft = new NFTCalvin();
        nftAddress = address(nft);

        market = new NFTMarketCalvin(tokenAddress, nftAddress);
        marketAddress = address (market);

        deal(tokenAddress, buyer, price);
        vm.deal(buyer, ethPrice);

        vm.prank(seller);
        tokenId = nft.mint(seller, "tokenURI");
    }

    //seller list nft , buyer buy nft
    function test_offlineBuy_token_success() public {
        vm.label(buyer,"buyerLabel");
        vm.label(seller,"sellerLabel");

        //seller offline list nft and approve market
        vm.startPrank(seller);
        // permit content
        NFTMarketCalvin.LimitOrder memory limitOrder = NFTMarketCalvin.LimitOrder({
            seller: seller,
            tokenId: tokenId,
            tokenPrice: price,
            ethPrice: 0,
            deadline:block.timestamp + 60 * 60 
        });
        (uint8 v,bytes32 r,bytes32 s) = signLimitOrder(limitOrder);
        nft.approve(marketAddress,tokenId);
        vm.stopPrank();

        console.log("----before offlineBuy----");
        console.log("nft belong to :",nft.ownerOf(tokenId));
        console.log("buyer's token:",token.balanceOf(buyer));
        console.log("buyer's eth:",buyer.balance);
        console.log("seller's token:",token.balanceOf(seller));
        console.log("seller's eth:",seller.balance);

        //buyer approve token and buy nft 
        vm.startPrank(buyer);
        token.approve(marketAddress,price);
        market.offlineBuy(limitOrder,v,r,s);
        vm.stopPrank();

        console.log("----after offlineBuy----");
        console.log("nft belong to :",nft.ownerOf(tokenId));
        console.log("buyer's token:",token.balanceOf(buyer));
        console.log("buyer's eth:",buyer.balance);
        console.log("seller's token:",token.balanceOf(seller));
        console.log("seller's eth:",seller.balance);

        assertEq(nft.ownerOf(tokenId), buyer,"nft should be transferred to buyer");
        assertEq(token.balanceOf(seller), price, "seller should receive token");
        assertEq(market.getTokenPrice(tokenId), 0, "nft should be unlisted");
    }


        //seller list nft , buyer buy nft 
    function test_offlineBuy_eth_success() public {
        vm.label(buyer,"buyerLabel");
        vm.label(seller,"sellerLabel");

        //seller offline list nft and approve market
        vm.startPrank(seller);
        NFTMarketCalvin.LimitOrder memory limitOrder = NFTMarketCalvin.LimitOrder({
            seller: seller,
            tokenId: tokenId,
            tokenPrice: 0,
            ethPrice: ethPrice,
            deadline:block.timestamp + 60 * 60 
        });
        (uint8 v,bytes32 r,bytes32 s) = signLimitOrder(limitOrder);
        nft.approve(marketAddress,tokenId);
        vm.stopPrank();

        console.log("----before offlineBuy----");
        console.log("nft belong to :",nft.ownerOf(tokenId));
        console.log("buyer's token:",token.balanceOf(buyer));
        console.log("buyer's eth:",buyer.balance);
        console.log("seller's token:",token.balanceOf(seller));
        console.log("seller's eth:",seller.balance);

        //buyer approve token and buy nft
        vm.startPrank(buyer);
        token.approve(marketAddress,price);
        market.offlineBuy{value: ethPrice}(limitOrder,v,r,s);
        vm.stopPrank();

        console.log("----after offlineBuy----");
        console.log("nft belong to :",nft.ownerOf(tokenId));
        console.log("buyer's token:",token.balanceOf(buyer));
        console.log("buyer's eth:",buyer.balance);
        console.log("seller's token:",token.balanceOf(seller));
        console.log("seller's eth:",seller.balance);

        assertEq(nft.ownerOf(tokenId), buyer,"nft should be transferred to buyer");
        assertEq(seller.balance,ethPrice, "seller should receive eth");
        assertEq(buyer.balance, 0, "buyer should decrease eth");
    }

    function test_offlineBuy_cancel_success() public {
        //seller offline list nft and approve market
        vm.startPrank(seller);
        NFTMarketCalvin.LimitOrder memory limitOrder = NFTMarketCalvin.LimitOrder({
            seller: seller,
            tokenId: tokenId,
            tokenPrice: 0,
            ethPrice: ethPrice,
            deadline:block.timestamp + 60 * 60 
        });
        //sign
        (uint8 v,bytes32 r,bytes32 s) = signLimitOrder(limitOrder);
        nft.approve(marketAddress,tokenId);
        //cancel sign
        market.cancelLimitOrder(limitOrder);

        
        //buyer approve token and buy nft
        vm.startPrank(buyer);
        token.approve(marketAddress, price);
        vm.expectRevert("limitOrder have been used");
        market.offlineBuy{value: ethPrice}(limitOrder,v,r,s);
        vm.stopPrank();

    }
    

    function signLimitOrder(NFTMarketCalvin.LimitOrder memory limitOrder) public view returns(uint8,bytes32,bytes32){
        // generate EIP-712 domainSeparator
        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("NFTMarketCalvin"),
            keccak256("1"),
            block.chainid,  // chainId
            marketAddress
        ));
        // generate limitOrder hash
        bytes32 limitOrderHash = keccak256(abi.encode(
            keccak256("LimitOrder(address seller,uint256 tokenId,uint256 tokenPrice,uint256 ethPrice,uint256 deadline)"),
            limitOrder.seller,
            limitOrder.tokenId,
            limitOrder.tokenPrice,  // valu
            limitOrder.ethPrice,  // nonce
            limitOrder.deadline  // deadline
        ));

        // generate full hash
        bytes32 fullHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, limitOrderHash));

        // sign message with privateKey and get ( r, s, v)
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sellerPK, fullHash);
        return ( v,r,s);
    }
}
