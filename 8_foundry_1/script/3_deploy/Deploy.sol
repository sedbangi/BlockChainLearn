// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../lib/forge-std/src/Script.sol";
import {MyToken} from "../../src/3_deploy/MyToken.sol";
import "../../lib/forge-std/src/console.sol";

contract Deploy is Script {

    function run() public {

        vm.startBroadcast(0x93acc3d06d476fd7d645c7eb79ad282eb3ec58a4c6283dd130aac0117ad97849);
        MyToken myToken = new MyToken("Calvin", "Calvin");
        vm.stopBroadcast();
    }


}