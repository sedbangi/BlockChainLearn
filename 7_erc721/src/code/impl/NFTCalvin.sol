// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "../INFTMarket.sol";

contract NFTCalvin is ERC721URIStorage{
    uint private _tokenIds;

    //mapping  nft(tokenId)  to  token(token address) to price(how much) ( nft priced by token(what kind of token))
    mapping (uint => mapping (address => uint)) public tokensPrice ;

    constructor() ERC721(unicode"CALVIN", "CALVIN") {}

    function mint(address to, string memory tokenURI) public returns (uint256) {
        _tokenIds++;
        uint256 newItemId = _tokenIds;
        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

}
