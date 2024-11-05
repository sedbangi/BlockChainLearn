// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";

contract Deploy2 is Script {

    function run() public {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        esRNT es = new esRNT();
        vm.stopBroadcast();
    }

}

contract esRNT {
    struct LockInfo{
        address user;
        uint64 startTime;
        uint256 amount;
    }
    LockInfo[] private _locks;
    constructor() {
        for (uint256 i = 0; i < 11; i++) {
            _locks.push(LockInfo(address(uint160(i+1)), uint64(block.timestamp*2-i), 1e18*(i+1)));
        }
    }
}
