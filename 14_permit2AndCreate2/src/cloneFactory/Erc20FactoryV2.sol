// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../lib/clone-factory/contracts/CloneFactory.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../lib/permit2/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import "./Token.sol";
import {console} from "../../lib/forge-std/src/console.sol";

/// @custom:oz-upgrades-from Erc20Factory
contract Erc20FactoryV2 is CloneFactory, Initializable{

    // Token attributes mapping
    mapping(address => TokenAttribute) public tokens;
    // Token attribute struct
    struct TokenAttribute {
        uint perMint;       // Tokens per mint
        uint totalSupply;   // Total supply of the token
        uint price;         // Price of the token
    }
    // State variables
    address public implAddress; // Implementation address for clone
    address public owner;        // Owner of the contract


    modifier onlyOwner() {
        require(owner == msg.sender,"Only Owner");
        _;
    }
    function initialize(address owner_) public initializer {
        owner = owner_;
    }


    //only owner can set implAddress
    function setImplAddress(address _implAddress) public onlyOwner {
        implAddress = _implAddress;
    }

    //any user can call this to deploy token
    function deployInscription(string memory symbol, uint totalSupply, uint perMint, uint price) public returns (address){
        address tokenAddress = createToken(symbol,symbol);
        tokens[tokenAddress] = TokenAttribute({
            perMint: perMint,
            totalSupply: totalSupply,
            price: price
        });

        return tokenAddress;
    }

    //any user can only call this func to mint token.
    function mintInscription(address tokenAddr) public payable{
        TokenAttribute memory tokenAttribute = tokens[tokenAddr];
        require(tokenAttribute.totalSupply > 0, "this tokenAddr not exist or have no totalSupply");

        Token token = Token(tokenAddr);
        require(token.totalSupply() + tokenAttribute.perMint < tokenAttribute.totalSupply, "have reached to totalSupply");
        require(tokenAttribute.price*tokenAttribute.perMint == msg.value,"wrong eth value");

        Token(tokenAddr).mint(msg.sender, tokenAttribute.perMint);

    }

    function createToken(string memory _name, string memory _symbol) internal returns(address){
        require(implAddress!=address (0),"implAddress not set");
        address clone = createClone(implAddress);
        Token(clone).init(_name, _symbol);

        return clone;
    }

}
