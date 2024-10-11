// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Bank {

    mapping(address => uint256) public balances;

    // sort by desc
    address[3] public topThreeUsers;

    address payable public adminAddress;

    constructor() payable {
        adminAddress = payable(msg.sender);
        updateBalancesAndTopThreeUsers();
    }
 
    //user call this to desposit
    function deposit() public payable {
        updateBalancesAndTopThreeUsers();
    }

    //enable this contract address to receive eth
    //execute this func when receive eth
    receive() external payable {
        updateBalancesAndTopThreeUsers();
    }

    //execute when an undefined func is called
    fallback() external payable {}

    //withdraw contract address balance only for ADMIN_ADDRESS
    function withdraw() public {
        if (payable (msg.sender) == adminAddress) {
            adminAddress.transfer(address(this).balance);
        }
    }

    function updateBalancesAndTopThreeUsers() private {
        // update balance
        balances[msg.sender] += msg.value;

        // update topThreeUsers
        // Check if the sender is already in topThreeUsers
        bool exists = false;
        for (uint i = 0; i < topThreeUsers.length; i++) {
            if (topThreeUsers[i] == msg.sender) {
                exists = true;
                break;
            }
        }

        // compare new sender's balance with lowest balance in topThreeUsers
        if (!exists && balances[msg.sender] > balances[topThreeUsers[topThreeUsers.length - 1]]) {
            topThreeUsers[topThreeUsers.length - 1] = msg.sender;
        }
        // sort desc
        for (uint i = (topThreeUsers.length - 1); i > 0; i--) {
            if (balances[topThreeUsers[i]] > balances[topThreeUsers[i - 1]]) {
                address tmp = topThreeUsers[i];
                topThreeUsers[i] = topThreeUsers[(i - 1)];
                topThreeUsers[(i - 1)] = tmp;
            }
        }
    }
}
