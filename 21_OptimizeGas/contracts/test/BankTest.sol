// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/bank/Bank.sol";


contract BankTest is Test {

    Bank public bank;

    function setUp() public {
        bank = new Bank();
    }

    function test_Sort() public {
        //3579 11 13
        for(uint i = 3 ; i<=13;i=i+2){
            address tempAddr = address (uint160(i));
            vm.deal(tempAddr, i);
            vm.prank(tempAddr);
            bank.deposit{value: i}();
        }
        //2468 10 12
        for(uint i = 2 ; i<=12;i=i+2){
            address tempAddr = address (uint160(i));
            vm.deal(tempAddr, i);
            vm.prank(tempAddr);
            bank.deposit{value: i}();
        }

        console.log(bank.listSize());
        address keyAddr = address (1);
        address addr;
        for(uint i = 0 ; i<=9; i++){
            addr = bank.userAddresses(keyAddr);
            console.log("addr:",addr);
            console.log("balance:",bank.balances(addr));
            keyAddr = addr;
        }


    }



}
