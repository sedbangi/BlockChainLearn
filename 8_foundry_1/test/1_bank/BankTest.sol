// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../../src/1_bank/Bank.sol";

contract BankTest is Test {
    Bank public bank;

    address user1 = address(0x12345);
    address user2 = address(0x123456);
    uint256 userEthCount1 = 10 ether;
    uint256 userEthCount2 = 5 ether;

    event Deposit(address indexed user, uint amount);

    function setUp() public {
        bank = new Bank();
        //give user eth
        deal(user1, userEthCount1);
        deal(user2, userEthCount2);
    }

    function test_Event() public {


        vm.expectEmit();
        emit Deposit(user1, userEthCount1);

        vm.startPrank(user1);
        bank.depositETH{value: userEthCount1}();
        vm.stopPrank();


        vm.expectEmit();
        emit Deposit(user2, userEthCount2);

        vm.startPrank(user2);
        bank.depositETH{value: userEthCount2}();
        vm.stopPrank();
        

        uint balance1 = bank.balanceOf(user1);
        uint balance2 = bank.balanceOf(user2);
        assertEq(balance1, userEthCount1,"balance should change after deposit");
        assertEq(balance2, userEthCount2,"balance should change after deposit");
    }
}
