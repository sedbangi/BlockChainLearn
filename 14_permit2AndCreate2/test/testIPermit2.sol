// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/impl/CalvinERC20.sol";
import "../src/impl/Permit2Calvin.sol";
import "../src/IPermit2.sol";
import "../src/impl/TokenBank.sol";
import {Test, console} from "forge-std/Test.sol";

contract EIP2612Test is Test {
    address tokenAddress;
    address bankAddress;
    address permit2Address;

    CalvinERC20 token;
    TokenBank bank;
    Permit2Calvin permit2;

    address user;
    uint256 userPrivateKey;
    uint256 price;

    function setUp() public {
        token = new CalvinERC20();
        tokenAddress = address(token);

        permit2 = new Permit2Calvin();
        permit2Address = address(permit2);

        bank = new TokenBank(tokenAddress, permit2Address);
        bankAddress = address(bank);

        userPrivateKey = uint256(keccak256(abi.encode(vm.randomInt(),block.timestamp)));
        user = vm.addr(userPrivateKey);
    }

    //buyer deposit through permitDeposit
    function test_deposit_success() public {
        price = uint256(2000);
        deal(tokenAddress,user,price);

        console.log("----before deposit----");
        console.log("user's token:",token.balanceOf(user));
        console.log("bank's token:",token.balanceOf(bankAddress));
        console.log("user's token in bank:",bank.getBalance(user,tokenAddress));

        //buyer sign the permit  and  seller to use it

        //user approve
        vm.startPrank(user);
        token.approve(permit2Address,price);

        //sign
        (IPermit2.Permit2 memory permit, uint8 v,bytes32 r,bytes32 s) = signPermit2();



        bank.depositWithPermit2(permit,user,v,r,s);
        vm.stopPrank();

        console.log("----after deposit----");
        console.log("user's token:",token.balanceOf(user));
        console.log("bank's token:",token.balanceOf(bankAddress));
        console.log("user's token in bank:",bank.getBalance(user,tokenAddress));

    }



    function signPermit2() public view returns(IPermit2.Permit2 memory ,uint8,bytes32,bytes32){
        // generate EIP-712 domainSeparator
        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("Permit2"),
            keccak256("1"),
            block.chainid,  // chainId
            permit2Address
        ));
        // permit content
        IPermit2.Permit2 memory permit2 = IPermit2.Permit2({
            token: tokenAddress,
            to:bankAddress,
            amount:price,  // value
            nonce:0,      // nonce
            expire:block.timestamp + 60 * 60 // deadline
        });
        // generate permit hash
        bytes32 permitHash = keccak256(abi.encode(
            keccak256("Permit2(address token,address to,uint256 amount,uint256 expire,uint256 nonce)"),
            permit2.token,
            permit2.to,
            permit2.amount,
            permit2.expire,
            permit2.nonce
        ));

        // generate full hash
        bytes32 fullHash = keccak256(abi.encodePacked("\x19\x01", domainSeparator, permitHash));

        // sign message with privateKey and get ( r, s, v)
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, fullHash);
        return (permit2, v,r,s);
    }
}
