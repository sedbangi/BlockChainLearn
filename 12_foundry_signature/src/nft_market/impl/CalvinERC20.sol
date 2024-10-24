// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC20Token.sol";
import "../IEIP2612.sol";
import "../IERC1363Receiver.sol";
import "../../../lib/forge-std/src/console.sol";

contract CalvinERC20 is IERC20Token,IEIP2612 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;

    mapping(address => uint256) public nonces;

    //erc2612
    bytes32 constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 DOMAIN_SEPARATOR;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        // set name,symbol,decimals,totalSupply
        name = "Calvin";
        symbol = "Calvin";
        decimals = 18;
        totalSupply = 100 * 10 ** 18; //100 million

        balances[msg.sender] = totalSupply;

        DOMAIN_SEPARATOR = hashStruct(
            EIP712Domain({
                name: "Calvin",
                version: "1",
                chainId: block.chainid,
                verifyingContract: address(this)
            })
        );
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(
            balances[msg.sender] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(
            balances[_from] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            allowances[_from][msg.sender] >= _value,
            "ERC20: transfer amount exceeds allowance"
        );

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool success) {
        require(
            balances[_from] >= _value,
            "ERC20: transfer amount exceeds balance"
        );

        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool) {
        bool success = transfer(to, value);
        if (!success) {
            revert("tranfer failed");
        }

        if (isContract(to)) {
            IERC1363Receiver(to).tokensReceived(
                msg.sender,
                msg.sender,
                value,
                data
            );
        }
        return success;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function transferWithPermit(
        Permit calldata data,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(block.timestamp <= data.deadline, "expired");
        require(nonces[data.owner] == data.nonce, "invalid nonce");
        nonces[data.owner]++;
        require(verify(data, v, r, s), "invalid signature");
        _transfer(data.owner, data.spender, data.value);
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
    function hashStruct(Permit memory permit) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    permit.owner,
                    permit.spender,
                    permit.value,
                    permit.nonce,
                    permit.deadline
                )
            );
    }
    function verify(
        Permit memory permit,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool) {
        // Note: we need to use `encodePacked` here instead of `encode`.
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct(permit))
        );
        return ecrecover(digest, v, r, s) == permit.owner;
    }
}
