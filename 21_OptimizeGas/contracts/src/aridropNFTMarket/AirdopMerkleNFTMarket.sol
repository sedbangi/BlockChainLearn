//SPDX-License-Identifier: MIT


import "../../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "../../lib/forge-std/src/console.sol";

contract AirdopMerkleNFTMarket is Multicall, Ownable {

    address public tokenAddress;
    address public nftAddress;
    bytes32 public merkleRoot;

    mapping(uint => ListInfo) public listInfos;

    struct ListInfo {
        uint tokenId;
        uint price;
        address seller;
    }

    constructor(address _tokenAddress, address _nftAddress) Ownable(msg.sender){
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
    }

    function setMerkelRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function permitPrePay(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s) public {
        IERC20Permit(tokenAddress).permit(owner, spender, value, deadline, v, r, s);
    }

    function claimNFT(uint tokenId, bytes32[] calldata proof) public {
        //50% discount if buyer on whitelist
        //check white list and change price
        bool inWhileList = MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(msg.sender)));
        console.log(inWhileList);
        if (inWhileList) {
            //50% discount is to be borne by the seller
            listInfos[tokenId].price = listInfos[tokenId].price/2;
        }
        //buy
        buyNFT(tokenId);
    }


    function list(uint tokenId, uint price) public {
        ERC721URIStorage nft = ERC721URIStorage(nftAddress);
        require(nft.ownerOf(tokenId) != address(0), "tokenId must exist");
        require(
            msg.sender == nft.ownerOf(tokenId)
            || nft.isApprovedForAll(nft.ownerOf(tokenId), msg.sender)
            , "you must be the owner or operator"
        );
        require(
            nft.isApprovedForAll(nft.ownerOf(tokenId), address(this))
            || nft.getApproved(tokenId) == address(this)
            , "approve the market or set the market the operator of the owner before list"
        );
        listInfos[tokenId] = ListInfo(tokenId, price, msg.sender);
    }

    function buyNFT(uint tokenId) public {
        ERC721URIStorage nft = ERC721URIStorage(nftAddress);
        address seller = listInfos[tokenId].seller;
        uint price = listInfos[tokenId].price;

        require(seller != address(0), "tokenId must on list");

        address nftOwner = nft.ownerOf(tokenId);
        //transfer nft to buyer
        nft.transferFrom(nftOwner, msg.sender, tokenId);
        //transfer token to seller
        IERC20(tokenAddress).transferFrom(msg.sender, seller, price);
        //unlist tokenId
        listInfos[tokenId] = ListInfo(0, 0, address(0));
    }

}