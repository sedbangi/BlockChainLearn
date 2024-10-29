// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20Bank.sol";
import "../IERC20Token.sol";
import "../IEIP2612.sol";
import {console} from "../../lib/forge-std/src/console.sol";
import "../IPermit2.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract Permit2Calvin is IPermit2 {

    mapping(address => uint256) public nonces;

    //erc2612
    bytes32 constant PERMIT2_TYPEHASH =
    keccak256(
        "Permit2(address token,address to,uint256 amount,uint256 expire,uint256 nonce)"
    );
    bytes32 constant EIP712DOMAIN_TYPEHASH =
    keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 DOMAIN_SEPARATOR;

    constructor() {
        DOMAIN_SEPARATOR = hashStruct(
            EIP712Domain({
                name: "Permit2",
                version: "1",
                chainId: block.chainid,
                verifyingContract: address(this)
            })
        );
    }
    function permit2TransferFrom(
        Permit2 calldata permit2,
        address _owner,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        //check nonce
        require(permit2.nonce == nonces[_owner], "invalid nonce");
        nonces[_owner]++;
        //check expiration
        require(block.timestamp < permit2.expire,"invalid expire");
        //verify signature valid and msg.sender == signer
        require(verifyPermit2(permit2, _owner, v, r, s), "invalid signature");
        //transfer
        IERC20Token(permit2.token).transferFrom(_owner,permit2.to,permit2.amount);
    }

    function verifyPermit2(
        Permit2 memory permit2,
        address _owner,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool) {
        // Note: we need to use `encodePacked` here instead of `encode`.
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct(permit2))
        );
        return ecrecover(digest, v, r, s) == _owner;
    }

    function hashStruct(
        EIP712Domain memory eip712Domain
    ) internal pure returns (bytes32) {
        return
            keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(eip712Domain.name)),
                keccak256(bytes(eip712Domain.version)),
                eip712Domain.chainId,
                eip712Domain.verifyingContract
            )
        );
    }
    function hashStruct(Permit2 memory permit2) internal pure returns (bytes32) {
        return
            keccak256(
            abi.encode(
                PERMIT2_TYPEHASH,
                permit2.token,
                permit2.to,
                permit2.amount,
                permit2.expire,
                permit2.nonce
            )
        );
    }

}