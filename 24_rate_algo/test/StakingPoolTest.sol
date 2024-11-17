// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/StakingPool.sol";

contract StakingPoolTest is Test {


    //admin deploy token , staking pool
    //buyer1 deposit amount eth 1 from block 1-31
    //buyer2 deposit amount eth 1 from block 11-31
    //buyer3 deposit amount eth 2 from block 21-31
    // buyer 1 claim at block 31 and receive 100+50+25 token

    address public tokenAddress;
    Token public token;
    address public stakingPoolAddress;
    StakingPool public stakingPool;

    address public admin = vm.randomAddress();
    address public buyer1 = vm.randomAddress();
    address public buyer2 = vm.randomAddress();
    address public buyer3 = vm.randomAddress();

    uint public startBlockNumber = vm.randomUint();


    function setUp() public {
        vm.startPrank(admin);
        vm.roll(startBlockNumber);

        token = new Token("calvin","calvin");
        tokenAddress = address (token);

        stakingPool = new StakingPool(tokenAddress);
        stakingPoolAddress = address (stakingPool);

        token.setStakingPool(stakingPoolAddress);

        vm.stopPrank();
    }

    function test_claim_success() public {
        vm.deal(buyer1,1 ether);
        vm.deal(buyer2,1 ether);
        vm.deal(buyer3,2 ether);

        vm.startPrank(buyer1);
        vm.roll(startBlockNumber+1);
        stakingPool.stake{value: buyer1.balance}();
        vm.stopPrank();

        vm.startPrank(buyer2);
        vm.roll(startBlockNumber+11);
        stakingPool.stake{value: buyer2.balance}();
        vm.stopPrank();

        vm.startPrank(buyer3);
        vm.roll(startBlockNumber+21);
        stakingPool.stake{value: buyer3.balance}();
        vm.stopPrank();

        vm.startPrank(buyer1);
        vm.roll(startBlockNumber+31);
        stakingPool.claim();
        vm.stopPrank();

        assertEq(token.balanceOf(buyer1),175 ether,"buyer1 receive right token");
    }

}
