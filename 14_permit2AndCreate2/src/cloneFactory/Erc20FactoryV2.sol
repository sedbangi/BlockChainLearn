// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../lib/clone-factory/contracts/CloneFactory.sol";
import "../../lib/permit2/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import "./Token.sol";


contract Erc20FactoryV2 is CloneFactory{

    //this states are Inscription's Attributes. so put them there instead of erc20
    mapping(address => TokenAttribute) public tokens;

    address public implAddress;

    address public owner;

    struct TokenAttribute {
        uint perMint;
        uint totalSupply;
        uint price;
    }

    modifier onlyOwner() {
        require(owner == msg.sender,"Only Owner");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    event TokenCreated(address newTokenAddress);
    event ImplAddressChanged(address newImplAddress);
    event TokenMinted(address to, address tokenAddress, uint amount, uint price);

    //only owner can set implAddress
    function setImplAddress(address _implAddress) public onlyOwner {
        implAddress = _implAddress;
        emit ImplAddressChanged(_implAddress);
    }

    //any user can call this to deploy token
    function deployInscription(string memory symbol, uint totalSupply, uint perMint, uint price) public returns (address){
        address tokenAddress = createToken(symbol,symbol);
        tokens[tokenAddress] = TokenAttribute({
            perMint: perMint,
            totalSupply: totalSupply,
            price: price
        });

        emit TokenCreated(tokenAddress);
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

        emit TokenMinted(msg.sender, tokenAddr, tokenAttribute.perMint,  tokenAttribute.price);
    }

    function createToken(string memory _name, string memory _symbol) internal returns(address){
        require(implAddress!=address (0),"implAddress not set");
        address clone = createClone(implAddress);
        Token(clone).init(_name, _symbol);

        emit TokenCreated(clone);
        return clone;
    }

}
