// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPermit2 {

    struct Permit2 {
        // ERC20 token address
        address token;
        // address permissioned on the allowed tokens
        address to;
        // the maximum amount allowed to spend
        uint256 amount;
        // timestamp at which a spender's token allowances become invalid
        uint256 expire;
        // an incrementing value indexed per owner,token,and spender for each signature
        uint256 nonce;
    }

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    function permit2TransferFrom(
        Permit2 calldata permit2,
        address _owner,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
