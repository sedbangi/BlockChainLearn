//SPDX-License-Identifier: MIT


import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC1363Receiver.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {EIP712Upgradeable} from "../../lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/EIP712Upgradeable.sol";
import "../../lib/forge-std/src/console.sol";

/// @custom:oz-upgrades-from Market
contract MarketV2 is IERC1363Receiver, EIP712Upgradeable {

    address public tokenAddress;
    address public nftAddress;

    mapping(uint => ListInfo) public listInfos;

    struct ListInfo {
        uint tokenId;
        uint price;
        address seller;
    }
    bytes32 private constant LIST_INFO_TYPE_HASH = keccak256(
        "ListInfo(uint256 tokenId,uint256 price,address seller)"
    );

    function init(address _tokenAddress, address _nftAddress) public reinitializer(2) {
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
        __EIP712_init("calvin", "1");
    }


    function buyWithSignature(ListInfo memory listInfo, uint8 v, bytes32 r, bytes32 s) public {
        //check: verify signature
        require(verify(listInfo, v, r, s), "invalid signature");

        ERC721URIStorage nft = ERC721URIStorage(nftAddress);
        address seller = listInfo.seller;
        uint tokenId = listInfo.tokenId;
        uint price = listInfo.price;

        require(
            seller == nft.ownerOf(tokenId)
            || nft.isApprovedForAll(nft.ownerOf(tokenId), seller)
            , "seller must be the owner or operator"
        );
        require(
            nft.isApprovedForAll(nft.ownerOf(tokenId), address(this))
            || nft.getApproved(tokenId) == address(this)
            , "approve the market or set the market the operator of the owner before list"
        );

        //skip list and unList

        address nftOwner = nft.ownerOf(tokenId);
        //transfer nft to buyer
        nft.transferFrom(nftOwner, msg.sender, tokenId);
        //transfer token to seller
        IERC20(tokenAddress).transferFrom(msg.sender, seller, price);

    }

    function verify(
        ListInfo memory listInfo,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool) {
        bytes32 digest = _hashTypedDataV4(hashStruct(listInfo));
        //ensure the signer match the seller in limitOrder
        return ecrecover(digest, v, r, s) == listInfo.seller;
    }


    function hashStruct(ListInfo memory listInfo) internal pure returns (bytes32) {
        return
            keccak256(
            abi.encode(
                LIST_INFO_TYPE_HASH,
                listInfo.tokenId,
                listInfo.price,
                listInfo.seller
            )
        );
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
        listInfos[tokenId] = ListInfo(0,0,address (0));
    }

    function onTransferReceived(
        address operator,
        address from,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4){
        require(msg.sender == tokenAddress, "not support this token");
        (uint tokenId) = abi.decode(data, (uint));

        ERC721URIStorage nft = ERC721URIStorage(nftAddress);
        IERC20 erc20Token = IERC20(tokenAddress);
        address seller = listInfos[tokenId].seller;
        uint price = listInfos[tokenId].price;

        require(price == value, "paied tokens must equal to list price");
        address nftOwner = nft.ownerOf(tokenId);
        //transfer nft to buyer
        nft.transferFrom(nftOwner, operator, tokenId);
        //transfer token to seller
        erc20Token.transfer(seller, price);
        //unlist tokenId
        listInfos[tokenId] = ListInfo(0,0,address (0));

        return bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"));
    }

}