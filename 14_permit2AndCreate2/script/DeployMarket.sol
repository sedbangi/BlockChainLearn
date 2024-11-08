// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";
import "../lib/openzeppelin-foundry-upgrades/src/Upgrades.sol";
import "../src/NFTMarketUpgrade/NFT.sol";
import "../src/NFTMarketUpgrade/Token.sol";
import {Market} from "../src/NFTMarketUpgrade/Market.sol";
import {MarketV2} from "../src/NFTMarketUpgrade/MarketV2.sol";

contract DeployMarket is Script {

    function run() public {
        vm.startBroadcast(vm.envUint("privateKey"));
        address addr = vm.addr(vm.envUint("privateKey"));
        //deploy nft and token
        Token token = new Token("calvin", "calvin");
        address tokenAddress = address(token);
        //deploy nft
        NFT nft = new NFT("calvin", "calvin");
        address nftAddress = address(nft);

        //proxy
        bytes memory initData = abi.encodeWithSelector(Market.init.selector,tokenAddress,nftAddress);
        address proxyAddress = Upgrades.deployTransparentProxy("Market.sol",addr,initData);
        //marketV1Addr
        address marketV1Addr = Upgrades.getImplementationAddress(proxyAddress);

        //upgrade
        initData = abi.encodeWithSelector(MarketV2.init.selector,tokenAddress,nftAddress);
        Upgrades.upgradeProxy(
            proxyAddress,
            "MarketV2.sol",
            initData
        );
        //marketV2Addr
        address marketV2Addr = Upgrades.getImplementationAddress(proxyAddress);
        vm.stopBroadcast();

        console.log("addr:", addr);
        console.log("proxy addr:", proxyAddress);
        console.log("token addr:", tokenAddress);
        console.log("nft addr:", nftAddress);
        console.log("v1 addr:", marketV1Addr);
        console.log("v2 addr:", marketV2Addr);
    }
}