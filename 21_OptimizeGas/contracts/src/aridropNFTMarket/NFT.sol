//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage{

    uint private tokenIdCount;

    // Optional mapping for token URIs
    mapping(uint256 tokenId => string) private _tokenURIs;

    constructor(string memory _name,string memory _symbol) ERC721 (_name,_symbol) {}

    function mint(string memory tokenURI) public returns(uint){
        tokenIdCount++;
        _mint(msg.sender,tokenIdCount);
        _setTokenURI(tokenIdCount,tokenURI);
        return tokenIdCount;
    }

}