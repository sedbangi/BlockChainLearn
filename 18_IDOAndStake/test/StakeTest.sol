// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/RNT.sol";
import {ESRNT} from "../src/ESRNT.sol";
import {Stake} from "../src/Stake.sol";


contract StakeTest is Test {


    address public adminAddress;
    address public rntAddress;
    address public esRNTAddress;
    address public stakeAddress;
    address public userAddress;

    RNT public rnt;
    ESRNT public esRNT;
    Stake public stake;

    uint public userTokenAmount = 1 * 10 ** 18;
    uint public stakeRewardAmount = 50 * 10 ** 18;


    function setUp() public {
        adminAddress = vm.randomAddress();
        userAddress = vm.randomAddress();

        vm.startPrank(adminAddress);
        //admin create token
        rnt = new RNT("RNT", "RNT");
        rntAddress = address(rnt);
        //admin create esToken
        esRNT = new ESRNT("ESRNT", "ESRNT", rntAddress);
        esRNTAddress = address(esRNT);
        //admin create stake
        stake = new Stake(rntAddress, esRNTAddress);
        stakeAddress = address(stake);
        //admin set stakePool
        esRNT.setStakePool(stakeAddress);
        //admin transfer RNT to pool
        rnt.transfer(stakeAddress, stakeRewardAmount);
        vm.stopPrank();

    }

    function test_stake_claim_burn_unStake_success() public {
        //user stake userTokenAmount. 1day past ,user claim and unStake, another 15 days past, user burn
        userAddress = vm.randomAddress();
        deal(rntAddress, userAddress, userTokenAmount);
        //user stake
        vm.startPrank(userAddress);
        //approve
        rnt.approve(stakeAddress,userTokenAmount);
        stake.stake(userTokenAmount);
        //user claim 1day past
        vm.warp(block.timestamp+ 1 days);
        stake.claim();
        stake.unStake(userTokenAmount);
        //user burn another 15 days
        vm.warp(block.timestamp + 15 days);
        esRNT.burn(0);
        vm.stopPrank();

        //user should
        assertEq(rnt.balanceOf(userAddress),userTokenAmount*3/2, "user finally get 1.5 ether token");
    }


}
