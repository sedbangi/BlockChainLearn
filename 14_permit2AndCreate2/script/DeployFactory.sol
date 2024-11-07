// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";
import "../lib/openzeppelin-foundry-upgrades/src/Upgrades.sol";
import {Erc20Factory} from "../src/cloneFactory/Erc20Factory.sol";
import {Erc20FactoryV2} from "../src/cloneFactory/Erc20FactoryV2.sol";

contract DeployFactory is Script {

    function run() public {
        vm.startBroadcast(vm.envUint("privateKey"));
        address addr = vm.addr(vm.envUint("privateKey"));
        //proxy
        bytes memory initData = new bytes(0);
        address proxyAddress = Upgrades.deployTransparentProxy("Erc20Factory.sol",addr,initData);
        //factoryV1Addr
        address factoryV1Addr = Upgrades.getImplementationAddress(proxyAddress);

        //upgrade
        Upgrades.upgradeProxy(
            proxyAddress,
            "Erc20FactoryV2.sol",
            abi.encodeCall(Erc20FactoryV2.initialize, (addr))
        );
        //factoryV2Addr
        address factoryV2Addr = Upgrades.getImplementationAddress(proxyAddress);
        vm.stopBroadcast();

        console.log("addr:", addr);
        console.log("proxy addr:", proxyAddress);
        console.log("v1 addr:", factoryV1Addr);
        console.log("v2 addr:", factoryV2Addr);
    }
}