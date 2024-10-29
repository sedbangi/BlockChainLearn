// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/nft_market/impl/CalvinERC20.sol";
import "../src/nft_market/impl/NFTCalvin.sol";
import "../src/nft_market/impl/TokenBank.sol";
import "../src/nft_market/impl/NFTMarketCalvin.sol";

contract EIP2612Test is Test {
    address tokenAddress;
    address bankAddress;
    address nftAddress;
    address marketAddress;


    CalvinERC20 token;
    TokenBank bank;
    NFTCalvin nft;
    NFTMarketCalvin market;

    uint public buyerPK = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint public sellerPK = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint public nftProjectLauncherPK = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
    address public buyer = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public seller = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    address public nftProjectLauncher = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
    uint public price = 200;
    uint public tokenId;

    address [] public _whiteList = [buyer];

    function setUp() public {
        token = new CalvinERC20();
        tokenAddress = address(token);

        bank = new TokenBank(tokenAddress);
        bankAddress = address(bank);

        vm.startPrank(nftProjectLauncher);
        nft = new NFTCalvin();
        nftAddress = address(nft);

        market = new NFTMarketCalvin(tokenAddress, nftAddress);
        marketAddress = address (market);
        vm.stopPrank();
        console.log("-----------tokenAddress:",tokenAddress);
        deal(tokenAddress, buyer, price);

        vm.prank(seller);
        tokenId = nft.mint(seller, "tokenURI");
    }

    //buyer deposit through permitDeposit
    function test_deposit_success() public {
        console.log("----before deposit----");
        console.log("buyer's token:",token.balanceOf(buyer));
        console.log("bank's token:",token.balanceOf(bankAddress));
        console.log("buyer's token in bank:",bank.getBalance(buyer,tokenAddress));
        //buyer sign the permit  and  seller to use it

        //sign
        vm.startPrank(buyer);
        (CalvinERC20.Permit memory permit, uint8 v,bytes32 r,bytes32 s) = signPermit();
        vm.stopPrank();

        vm.startPrank(seller);
        bank.permitDeposit(permit,v,r,s);
        vm.stopPrank();

        console.log("----after deposit----");
        console.log("buyer's token:",token.balanceOf(buyer));
        console.log("bank's token:",token.balanceOf(bankAddress));
        console.log("buyer's token in bank:",bank.getBalance(buyer,tokenAddress));

        assertEq(token.balanceOf(bankAddress), price,"bank should get token");
        assertEq(bank.getBalance(buyer,tokenAddress), price, "bank should record buyer's deposit");
    }


    //seller list nft , buyer buy nft with whiteList
    function test_permitBuy_success() public {
        vm.label(buyer,"buyerLabel");
        vm.label(seller,"sellerLabel");

        //projectLauncher sign the white list
        vm.startPrank(nftProjectLauncher);
        (CalvinERC20.WhiteList memory whiteList, uint8 v,bytes32 r,bytes32 s) = signWhiteList();
        vm.stopPrank();

        //seller list nft and approve market
        vm.startPrank(seller);
        market.list(tokenId, price);
        nft.approve(marketAddress,tokenId);
        vm.stopPrank();

        console.log("----before permitBuy----");
        console.log("nft belong to :",nft.ownerOf(tokenId));
        console.log("buyer's token:",token.balanceOf(buyer));
        console.log("seller's token:",token.balanceOf(seller));
        console.log("whether nft on list:",market.getTokenPrice(tokenId) != 0);
        //buyer sign the permit  and  seller to use it

        //buyer approve token and buy nft with whiteList
        vm.startPrank(buyer);
        token.approve(marketAddress,price);
        market.permitBuy(tokenId,whiteList,v,r,s);
        vm.stopPrank();

        console.log("----after permitBuy----");
        console.log("nft belong to :",nft.ownerOf(tokenId));
        console.log("buyer's token:",token.balanceOf(buyer));
        console.log("seller's token:",token.balanceOf(seller));
        console.log("whether nft on list:",market.getTokenPrice(tokenId) != 0);

        assertEq(nft.ownerOf(tokenId), buyer,"nft should be transferred to buyer");
        assertEq(token.balanceOf(seller), price, "seller should receive token");
        assertEq(market.getTokenPrice(tokenId), 0, "nft should be unlisted");
    }

    function signPermit() public view returns(IEIP2612.Permit memory ,uint8,bytes32,bytes32){
        // generate EIP-712 domainSeparator
        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("Calvin"),
            keccak256("1"),
            block.chainid,  // chainId
            tokenAddress
        ));
        // permit content
        IEIP2612.Permit memory permit = IEIP2612.Permit({
            owner:buyer,
            spender:bankAddress,
            value:price,  // value
            nonce:0,      // nonce
            deadline:block.timestamp + 60 * 60 // deadline
        });
        // generate permit hash
        bytes32 permitHash = keccak256(abi.encode(
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
            permit.owner,
            permit.spender,
            permit.value,  // valu
            permit.nonce,  // nonce
            permit.deadline  // deadline
        ));

        // generate full hash
        bytes32 fullHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, permitHash));

        // sign message with privateKey and get ( r, s, v)
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyerPK, fullHash);
        return (permit, v,r,s);
    }

    function signWhiteList() public returns(IEIP2612.WhiteList memory ,uint8,bytes32,bytes32){
        // generate EIP-712 domainSeparator
        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("NFTMarketCalvin"),
            keccak256("1"),
            block.chainid,  // chainId
            marketAddress
        ));
        IEIP2612.WhiteList memory whiteList = IEIP2612.WhiteList({
            whiteList: _whiteList
        });


        // generate whiteList hash
        bytes32 whiteListHash = keccak256(abi.encode(
            keccak256("WhiteList(address[] whiteList)"),
            whiteList.whiteList
        ));

        // generate full hash
        bytes32 fullHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, whiteListHash));

        // sign message with privateKey and get ( r, s, v)
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(nftProjectLauncherPK, fullHash);
        return (whiteList, v,r,s);
    }
}
