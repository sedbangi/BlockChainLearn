// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../lib/forge-std/src/console.sol";

contract Bank {
    mapping(address => uint256) public balances;
    //top 10
    mapping(address => address) public userAddresses;
    address private constant GUARD = address(1);
    //defination: size include GUARD
    uint256 public listSize;

    constructor() {
        userAddresses[GUARD] = GUARD;
        listSize++;
    }

    //deposit(balance+ , sort)
    function deposit() public payable {
        require(msg.value > 0, "no eth received");
        balances[msg.sender] += msg.value;
        sort(msg.sender);
    }

    function sort(address addr) internal {
        if (listSize == 1) {
            //listSize: 1
            insertAddress(addr, GUARD);
            listSize++;
            return;
        }
        //listSize: [2~11]
        if (userAddresses[addr] != address(0)) {
            removeAddress(addr);
        }

        address currentKeyAddress = GUARD;
        for (uint256 i = 0; i < listSize - 1; i++) {
            //currentKeyAddress -> currentAddress
            address currentAddress = userAddresses[currentKeyAddress];
            if (balances[addr] > balances[currentAddress]) {
                //insert
                insertAddress(addr, currentKeyAddress);
                //keep listSize<=11
                handleListSize();
                break;
            }
            currentKeyAddress = currentAddress;
        }
    }

    function handleListSize() internal {
        if (listSize < 11) {
            listSize++;
            return;
        }
        //cut the last element
        address currentKeyAddress = GUARD;
        for (uint256 i = 0; i < 10; i++) {
            //currentKeyAddress -> currentAddress
            address currentAddress = userAddresses[currentKeyAddress];
            currentKeyAddress = currentAddress;
        }
        removeAddress(currentKeyAddress);
    }

    //keyAddress -> Address   to  keyAddress -> newAddress -> Address
    function insertAddress(address newAddress, address keyAddress) internal {
        require(newAddress != address(0));
        require(userAddresses[newAddress] == address(0));
        userAddresses[newAddress] = userAddresses[keyAddress];
        userAddresses[keyAddress] = newAddress;
    }

    // keyAddress -> toBeRemovedAddress -> Address to  keyAddress -> Address
    function removeAddress(address keyAddress) internal {
        userAddresses[keyAddress] = userAddresses[userAddresses[keyAddress]];
    }

    // keyAddress -> toBeReplacedAddress -> Address to  keyAddress -> newAddress -> Address
    function replaceAddress(address newAddress, address keyAddress) internal {
        require(newAddress != address(0));
        require(userAddresses[newAddress] == address(0));
        userAddresses[newAddress] = userAddresses[userAddresses[keyAddress]];
        userAddresses[keyAddress] = newAddress;
    }
}
