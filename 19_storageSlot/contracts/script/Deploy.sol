// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";

contract Deploy is Script {

    function run() public {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        MyWallet myWallet = new MyWallet("calvin");
        console.log(address (myWallet));
        console.log(myWallet.owner());
        vm.stopBroadcast();
    }

}

contract MyWallet {
    string public name;
    mapping (address => bool) privateapproved;
    address public owner;
    modifier auth {
        require (msg.sender == owner, "Not authorized");
        _;
    }
    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }
    function getOwner() public returns(address _owner){
        assembly{
            _owner := sload(1)
        }
    }

    function transferOwernship(address _addr) public auth {
        require(_addr!=address(0), "New owner is the zero address");
        require(owner != _addr, "New owner is the same as the old owner");
        assembly{
            sstore(1, _addr)
        }
    }
}