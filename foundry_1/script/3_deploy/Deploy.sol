// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../lib/forge-std/src/Script.sol";
import {MyToken} from "../../src/3_deploy/MyToken.sol";
import "../../lib/forge-std/src/console.sol";

contract Deploy is Script {

    function run() public {
        vm.startPrank(0x9b5f8b67660a863B7ac82F720b9F29F9b872Df58);

        MyToken myToken = new MyToken("Calvin", "Calvin");

        console.log("address:",address (myToken));
        console.log("name:",myToken.name());
        console.log("balanceOf:",myToken.balanceOf(0x9b5f8b67660a863B7ac82F720b9F29F9b872Df58));
        console.log("totalSupply:",myToken.totalSupply());
        vm.stopPrank();

        //https://sepolia.etherscan.io/address/0xf3da665f65e287f6c5c51b35e89d2e10817c7e0b
    }


}