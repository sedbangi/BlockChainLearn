// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank public bank;

    address user = address(0x12345);
    uint256 userEthCount = 10 ether;

    event Deposit(address indexed user, uint amount);

    function setUp() public {
        bank = new Bank();
        //give user eth
        deal(user, userEthCount);
    }

    function test_Event() public {
        vm.expectEmit(true, false, false, true);
        emit Deposit(user, userEthCount);

        //deposit
        vm.startPrank(user);
        bank.depositETH{value: userEthCount}();
        vm.stopPrank();

        uint balance = bank.balanceOf(user);

        assertEq(balance, userEthCount,"balance should change after deposit");
    }
}
