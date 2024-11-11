// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/Bank.sol";

contract DeployBank is Script {

    function run() public {
        vm.startBroadcast(vm.envUint("privateKey"));

        new Bank(100000000000000000);

        vm.stopBroadcast();
    }
}
