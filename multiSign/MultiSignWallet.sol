// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MultiSignWallet {
    //owners
    address[] public owners;
    mapping(address => bool) public isOwner;

    //confirm numbers needed to execute tnx
    uint256 public required;

    //transaction
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 confirmedCount;
        mapping(address => bool) confirmed;
        bool executed;
    }

    //record transactions
    Transaction[] public transactions;

    constructor(address[] memory _owners, uint256 _required) {
        for (uint256 i = 0; i < _owners.length; i++) {
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
        required = _required;
    }

    modifier onlyOwners() {
        require(isOwner[msg.sender], "Only Owners!");
        _;
    }

    event SubmitTransaction(
        address msgSender,
        address to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address msgSender, uint256 transactionIndex);
    event ExecuteTransaction(address msgSender, uint256 transactionIndex);

    //msg.sender submitTransaction with transaction basic info (to value data)
    function submitTransaction(address to, uint256 value, bytes calldata data) public onlyOwners {
        //create transaction
        uint256 newTransactionIndex = transactions.length;
        transactions.push();
        Transaction storage t = transactions[newTransactionIndex];
        t.to = to;
        t.value = value;
        t.data = data;
        //emit event
        emit SubmitTransaction(msg.sender, to, value, data);
    }

    //owner can confirmTnx (Once)
    function confirmTransaction(uint256 transactionIndex) public onlyOwners {
        Transaction storage t = transactions[transactionIndex];
        require(t.executed != true, "tnx has been executed");
        require(!t.confirmed[msg.sender], "you have confirmed");

        t.confirmed[msg.sender] = true;
        t.confirmedCount += 1;
        //emit event
        emit ConfirmTransaction(msg.sender, transactionIndex);

        //once confirmedCount reach to required ,auto executeTransaction
        if (t.confirmedCount == required) {
            executeTransaction(transactionIndex);
        }
    }

    //execute tnx
    function executeTransaction(uint256 transactionIndex) internal onlyOwners {
        Transaction storage t = transactions[transactionIndex];
        //call
        (bool callResult, ) = address(t.to).call{value: t.value}(t.data);
        //update t
        t.executed = true;
        require(callResult, "call failed");
        //emit event
        emit ExecuteTransaction(msg.sender, transactionIndex);
    }
}
