// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "../INFTMarket.sol";

contract NFTCalvin is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //mapping  nft(tokenId)  to  token(token address) to price(how much) ( nft priced by token(what kind of token))
    mapping (uint => mapping (address => uint)) public tokensPrice ;

    constructor() ERC721(unicode"CALVIN", "CALVIN") {}

    function mint(address to, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

}
