//SPDX-License-Identifier: MIT


import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC1363Receiver.sol";
import "../../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../lib/forge-std/src/interfaces/IERC721.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Market is IERC1363Receiver, Initializable {

    address public tokenAddress;
    address public nftAddress;

    mapping(uint => ListInfo) public listInfos;

    struct ListInfo {
        uint price;
        address seller;
    }

    function init(string memory _tokenAddress, string memory _nftAddress) public initializer {
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
    }

    function list(uint tokenId, uint price) public {
        IERC721 nft = IERC721(nftAddress);
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
        listInfos[tokenId] = ListInfo(price, msg.sender);
    }

    function buyNFT(uint tokenId) public {
        IERC721 nft = IERC721(nftAddress);
        address seller = listInfos[tokenId].seller;
        uint price = listInfos[tokenId].price;

        require(seller != address(0), "tokenId must on list");

        address nftOwner = nft.ownerOf(tokenId);
        //transfer nft to buyer
        nft.transferFrom(nftOwner, msg.sender, tokenId);
        //transfer token to seller
        IERC20(tokenAddress).transferFrom(msg.sender, seller, price);
        //unlist tokenId
        listInfos[tokenId] = 0;
    }

    function onTransferReceived(
        address operator,
        address from,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4){
        require(msg.sender == tokenAddress, "not support this token");
        (uint tokenId) = abi.decode(data,(uint));

        IERC721 nft = IERC721(nftAddress);
        IERC20 erc20Token = IERC20(tokenAddress);
        address seller = listInfos[tokenId].seller;
        uint price = listInfos[tokenId].price;

        require(price == value,"paied tokens must equal to list price");
        address nftOwner = nft.ownerOf(tokenId);
        //transfer nft to buyer
        nft.transferFrom(nftOwner, operator, tokenId);
        //transfer token to seller
        erc20Token.transfer(seller, price);
        //unlist tokenId
        listInfos[tokenId] = 0;

        return bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"));
    }

}