// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";
import "../src/impl/CalvinERC20.sol";
import "../src/impl/TokenBank.sol";
import "../src/impl/Permit2Calvin.sol";

contract Deploy is Script {

    function run() public {
        vm.startBroadcast(vm.envUint("privateKey"));
        CalvinERC20 token = new CalvinERC20();
        Permit2Calvin permit2 = new Permit2Calvin();
        TokenBank tokenBank = new TokenBank(address (token),address (permit2));
        vm.stopBroadcast();
    }
}