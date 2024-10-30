// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../src/cloneFactory/Erc20FactoryV2.sol";
import "../lib/openzeppelin-foundry-upgrades/src/Upgrades.sol";
import {Erc20Factory} from "../src/cloneFactory/Erc20Factory.sol";
import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/cloneFactory/Token.sol";

contract testFactory is Test {
    address tokenAddress;
    address factoryAddress;
    address factory2Address;
    address proxyAddress;
    address proxyOwner = address (0x5);

    Token token;
    Erc20Factory factory;
    Erc20FactoryV2 factoryV2;


    function setUp() public {
        //erc20
        //factory1
        factory = new Erc20Factory();
        factoryAddress = address (factory);
        //proxy
        vm.startPrank(proxyOwner);
        bytes memory initData = new bytes(0);
        proxyAddress = Upgrades.deployTransparentProxy("Erc20Factory.sol",proxyOwner,initData);
        vm.stopPrank();
    }

    function test_factory_deploy_mint() public {

        address user1 = vm.randomAddress();
        address user2 = vm.randomAddress();
        address user3 = vm.randomAddress();
        uint permit = 2;
        Erc20Factory factoryProxy = Erc20Factory(proxyAddress);
        //user 1 deploy
        vm.prank(user1);
        tokenAddress = factoryProxy.deployInscription('symbol',100,permit);
        //user 2 mint
        vm.prank(user2);
        factoryProxy.mintInscription(tokenAddress);
        //user 3 mint
        vm.prank(user3);
        factoryProxy.mintInscription(tokenAddress);
        //user 3 mint again
        vm.prank(user3);
        factoryProxy.mintInscription(tokenAddress);

        //balanceOf user 1
        console.log('user1 balance',Token(tokenAddress).balanceOf(user1));
        //balanceOf user 2
        console.log('user2 balance',Token(tokenAddress).balanceOf(user2));
        //balanceOf user 3
        console.log('user3 balance',Token(tokenAddress).balanceOf(user3));
        //token real totalSupply
        console.log('token real totalSupply',Token(tokenAddress).totalSupply());

        assertEq(Token(tokenAddress).balanceOf(user1),0,"deployer own 0 initial");
        assertEq(Token(tokenAddress).balanceOf(user2),permit,"mint wrong");
        assertEq(Token(tokenAddress).balanceOf(user3),permit*2,"multi mint wrong");
    }


    function testFactoryV2() public {
        //factoryV1 deploy one token
        Erc20Factory factoryProxy = Erc20Factory(proxyAddress);
        address v1TokenAddr = factoryProxy.deployInscription("v1Token",100,1);
        //proxy state
        (uint perMintV1, uint totalSupplyV1) = factoryProxy.tokens(v1TokenAddr);
        console.log(perMintV1);
        console.log(totalSupplyV1);

        //upgrade v1 to v2
        vm.startPrank(proxyOwner);
        Upgrades.upgradeProxy(
            proxyAddress,
            "Erc20FactoryV2.sol",
            abi.encodeCall(Erc20FactoryV2.initialize, (proxyOwner))
        );
        Erc20FactoryV2 factoryProxyV2 = Erc20FactoryV2(proxyAddress);
        factoryProxyV2.setImplAddress(address(new Token()));
        vm.stopPrank();
        //proxy state

        (uint perMintV2, uint totalSupply2, uint price) = factoryProxyV2.tokens(v1TokenAddr);
        console.log(perMintV2);
        console.log(totalSupply2);
        //check state after upgrade
        assertEq(perMintV1,perMintV2,"state changed");
        assertEq(totalSupplyV1,totalSupply2,"state changed");

        //mint and check
        address user1 = vm.randomAddress();
        address user2 = vm.randomAddress();
        vm.deal(user2,100);
        address user3 = vm.randomAddress();
        vm.deal(user3,100);
        uint permit = 2;
        uint tempPrice = 1;
        //user 1 deploy
        vm.prank(user1);
        tokenAddress = factoryProxyV2.deployInscription('symbol',100,permit,tempPrice);
        //user 2 mint
        vm.prank(user2);
        factoryProxyV2.mintInscription{value: 2}(tokenAddress);
        //user 3 mint
        vm.prank(user3);
        factoryProxyV2.mintInscription{value: 2}(tokenAddress);
        //user 3 mint again
        vm.prank(user3);
        factoryProxyV2.mintInscription{value: 2}(tokenAddress);

        //balanceOf user 1
        console.log('user1 balance',Token(tokenAddress).balanceOf(user1));
        //balanceOf user 2
        console.log('user2 balance',Token(tokenAddress).balanceOf(user2));
        //balanceOf user 3
        console.log('user3 balance',Token(tokenAddress).balanceOf(user3));
        //token real totalSupply
        console.log('token real totalSupply',Token(tokenAddress).totalSupply());

        assertEq(Token(tokenAddress).balanceOf(user1),0,"deployer own 0 initial");
        assertEq(Token(tokenAddress).balanceOf(user2),permit,"mint wrong");
        assertEq(Token(tokenAddress).balanceOf(user3),permit*2,"multi mint wrong");

    }




}