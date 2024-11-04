// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/RNT.sol";
import {IDO} from "../src/IDO.sol";


contract IDOTest is Test {

    address public adminAddress;
    address public tokenAddress;
    address public IDOAddress;
    address public buyerA;
    address public buyerB;

    RNT public rnt;
    IDO public ido;

    uint public tokenAmount =50 * 10**18;
    uint public targetETHAmount = 100 ether;
    uint public maxETHAmount = 200 ether;
    uint public deadline = block.timestamp + 3*24*60*60;


    function setUp() public {
        adminAddress = vm.randomAddress();
        //create token
        vm.startPrank(adminAddress);

        rnt = new RNT("RNT","RNT");
        tokenAddress = address (rnt);

        ido = new IDO();
        IDOAddress = address (ido);
        //transfer token to IDO and publish token
        rnt.transfer(IDOAddress,tokenAmount);
        ido.publishIDO(IDO.PresaleRule({
            tokenAddress: tokenAddress,
            admin: adminAddress,
            tokenAmount: tokenAmount,
            targetETHAmount: targetETHAmount,
            maxETHAmount: maxETHAmount,
            deadline: deadline
        }));

        vm.stopPrank();

    }

    function test_presale_success() public {
        buyerA = vm.randomAddress();
        buyerB = vm.randomAddress();
        vm.deal(buyerA,70 ether);
        vm.deal(buyerB,70 ether);
        //user A B call presale
        vm.prank(buyerA);
        ido.presale{value: buyerA.balance}(tokenAddress);

        vm.prank(buyerB);
        ido.presale{value: buyerB.balance}(tokenAddress);

        //user A B claim
        vm.warp(block.timestamp + 5 days);

        vm.prank(buyerA);
        ido.claim(tokenAddress);

        vm.prank(buyerB);
        ido.claim(tokenAddress);

        //admin withdraw
        vm.prank(adminAddress);
        ido.withdraw(tokenAddress);

        //check AB token and admin ETH
        assertEq(rnt.balanceOf(buyerA) , tokenAmount/2 ,"buyerA should receive half presale token");
        assertEq(rnt.balanceOf(buyerB) , tokenAmount/2 ,"buyerB should receive half presale token");
        assertEq(adminAddress.balance , 140 ether ,"admin should receive all the eth");
    }

    function test_presale_fail_refund() public {
        buyerA = vm.randomAddress();
        buyerB = vm.randomAddress();
        vm.deal(buyerA,10 ether);
        vm.deal(buyerB,10 ether);
        //user A B call presale
        vm.prank(buyerA);
        ido.presale{value: buyerA.balance}(tokenAddress);

        vm.prank(buyerB);
        ido.presale{value: buyerB.balance}(tokenAddress);

        //user A B claim fail and refund
        vm.warp(block.timestamp + 5 days);

        vm.startPrank(buyerA);
        vm.expectRevert("haven't raised enough ETH");
        ido.claim(tokenAddress);
        ido.refund(tokenAddress);
        vm.stopPrank();

        vm.startPrank(buyerB);
        vm.expectRevert("haven't raised enough ETH");
        ido.claim(tokenAddress);
        ido.refund(tokenAddress);
        vm.stopPrank();


        //check AB token and admin ETH
        assertEq(rnt.balanceOf(buyerA) , 0 ,"buyerA should receive half presale token");
        assertEq(rnt.balanceOf(buyerB) , 0 ,"buyerB should receive half presale token");
        assertEq(buyerA.balance , 10 ether ,"buyerA's eth shouldn't change");
        assertEq(buyerB.balance , 10 ether ,"buyerB's eth shouldn't change");
    }

}
