// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "fs/Test.sol";
import "src/2_nft_market/IERC20Token.sol";
import "src/2_nft_market/IERC1363Receiver.sol";
import "src/2_nft_market/INFTMarket.sol";
import "src/2_nft_market/impl/CalvinERC20.sol";
import "src/2_nft_market/impl/NFTCalvin.sol";
import "src/2_nft_market/impl/NFTMarketCalvin.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract testNFTMarket is Test {

    /*
    token  address
    nft address
    nft market address

    buyer：		0x4
    seller：		0x5
    tokenId:
    */
    address public tokenAddress;
    address public nftAddress;
    address public marketAddress;

    CalvinERC20 public tokenAddressInstance;
    NFTCalvin public nftAddressInstance;
    NFTMarketCalvin public marketAddressInstance;

    address public buyer = address(0x4);
    address public seller = address(0x5);
    uint public tokenId;
    uint public price = 200;

    /*
    setUp:
        buyer 		own 	200
        seller 		own 	0
        mint one	tokenId	1
    */
    function setUp() public {
        tokenAddressInstance = new CalvinERC20();
        nftAddressInstance = new NFTCalvin();
        tokenAddress = address(tokenAddressInstance);
        nftAddress = address(nftAddressInstance);

        marketAddressInstance = new NFTMarketCalvin(tokenAddress, nftAddress);
        marketAddress = address(marketAddressInstance);

        deal(tokenAddress, buyer, price);

        vm.prank(seller);
        tokenId = nftAddressInstance.mint(seller, "tokenURI");
    }

    /*
    test_list_success
        act:
            1. seller:	list
            2. seller:	approve market
        check:
            1. nft belong to seller
            2. nft on list and pirce is right
            2. nft approved to market
    */
    function test_list_success() public {
        //assert list_event
        vm.expectEmit();
        emit NFTMarketCalvin.listEvent(tokenId, price);

        vm.startPrank(seller);
        marketAddressInstance.list(tokenId, price);
        nftAddressInstance.approve(marketAddress, tokenId);
        vm.stopPrank();

        //assert list result
        assertEq(nftAddressInstance.ownerOf(tokenId), seller, "nft still belong to seller");
        assertEq(marketAddressInstance.tokensPrice(tokenId), price, "tokenId must on list with a right price");
        assertEq(nftAddressInstance.getApproved(tokenId), marketAddress, "nft must approve to market");
    }

    /*
    test_list_failure (buyer list token)
        act:
            1. buyer:	list
        check:
            1. Only owner or approved can call this function
    */
    function test_list_failure() public {
        vm.startPrank(buyer);
        //assert revert
        vm.expectRevert("Only owner or approved can call this function");
        marketAddressInstance.list(tokenId, price);
        vm.stopPrank();
    }

    /*
        test_buy_success
        act:
            pre: list
            1. buyer:	approve market
            2. buyer:	buy
        check:
            1. balanceOf seller :200
            2. balanceOf buyer:	0
            3. nft belong to : buyer
            4. unlist nft
    */
    function test_buy_success() public {
        //seller: list
        vm.startPrank(seller);
        marketAddressInstance.list(tokenId, price);
        nftAddressInstance.approve(marketAddress, tokenId);
        vm.stopPrank();

        //buyer: approve market and buy
        vm.startPrank(buyer);
        tokenAddressInstance.approve(marketAddress, price);
        //assert buyEvent
        vm.expectEmit();
        emit NFTMarketCalvin.buyEvent(buyer, tokenId, price);

        marketAddressInstance.buyNFT(tokenId);
        vm.stopPrank();

        assertEq(tokenAddressInstance.balanceOf(seller), 200, "seller get the token");
        assertEq(tokenAddressInstance.balanceOf(buyer), 0, "buyer pays the token");
        assertEq(nftAddressInstance.ownerOf(tokenId), buyer, "buyer get the nft");
        assertEq(marketAddressInstance.tokensPrice(tokenId), 0, "nft should unlist");
    }

    /*
    test_buy_failure_self_buy
    act:
        pre: list
        1. seller:	approve market
        2. seller:	buy
    check:
        1. you can't buy your nft
    */
    function test_buy_failure_self_buy() public {
        //seller: list
        vm.startPrank(seller);
        marketAddressInstance.list(tokenId, price);
        nftAddressInstance.approve(marketAddress, tokenId);

        //seller: approve market and buy
        tokenAddressInstance.approve(marketAddress, price);
        //assert revert :you can buy your nft
        vm.expectRevert(abi.encodeWithSignature("BuyOwnNFT(uint256)", tokenId));
        marketAddressInstance.buyNFT(tokenId);

        vm.stopPrank();
    }

    /*
    test_buy_failure_multi_buy
    act:
        pre: list
        1. buyer:	approve market
        2. buyer:	buy
    check:
        1. tokenId must on list
    */
    function test_buy_failure_multi_buy() public {
        //seller: list
        vm.startPrank(seller);
        marketAddressInstance.list(tokenId, price);
        nftAddressInstance.approve(marketAddress, tokenId);
        vm.stopPrank();

        //buyer: approve market and buy
        vm.startPrank(buyer);
        tokenAddressInstance.approve(marketAddress, price);
        marketAddressInstance.buyNFT(tokenId);
        //buy again
        deal(tokenAddress, buyer, 200);
        tokenAddressInstance.approve(marketAddress, price);

        vm.expectRevert("tokenId must on list");
        marketAddressInstance.buyNFT(tokenId);
        vm.stopPrank();
    }

    /*
    test_buy_failure_wrong_price
    act:
        pre:list
        1. buyer: transferAndCall
    check:
        1. paied tokens must equal to list price
    */
    function test_buy_failure_wrong_price(uint randomPrice) public {
        //因为初始buyer的余额和nft的价格都设置的200 所有这里cheat buyer的余额
        deal(tokenAddress, buyer, 1000);
        vm.assume(0 < randomPrice && randomPrice < 1000 && randomPrice != price);
        //seller: list
        vm.startPrank(seller);
        marketAddressInstance.list(tokenId, price);
        nftAddressInstance.approve(marketAddress, tokenId);
        vm.stopPrank();

        //buyer: transferAndCall
        vm.startPrank(buyer);
        vm.expectRevert(abi.encodeWithSignature("PriceNotEqual(uint256,uint256)",tokenId,randomPrice));
        tokenAddressInstance.transferAndCall(marketAddress, randomPrice, abi.encode(tokenId));
        vm.stopPrank();
    }

    /*
    test_random_list_buy
        act:
            pre: random price list
            1. random address buy
        check:
            1. balanceOf seller :200
            2. balanceOf buyer:	0
            3. nft belong to : buyer
            4. unlist nft
    */
    function testFuzz_random_list_buy (uint randomPrice, address randomBuyer) public {
        //nft price and buyer balance: 0.01-10000
        vm.assume(randomPrice>= 0.01 * 10**18 && randomPrice <=10000 * 10**18 && randomBuyer != seller);
        deal(tokenAddress,randomBuyer,randomPrice);
        //seller: list
        vm.startPrank(seller);
        marketAddressInstance.list(tokenId, randomPrice);
        nftAddressInstance.approve(marketAddress, tokenId);
        vm.stopPrank();

        //buyer: approve market and buy
        vm.startPrank(randomBuyer);
        tokenAddressInstance.approve(marketAddress, randomPrice);
        marketAddressInstance.buyNFT(tokenId);
        vm.stopPrank();
    }

    function invariant_market_own_no_token() public {
        console.log("Checking market ownership of tokens...");
        assertEq(tokenAddressInstance.balanceOf(marketAddress),0,"market own no tokens");
    }


}
