import { createPublicClient, http } from 'viem';
import { mainnet } from 'viem/chains'
import { ethers } from 'ethers';

// 初始化 viem 客户端
const client = createPublicClient({
    chain: mainnet, // 使用主网
    transport: http(),
});

// NFT 合约地址
const nftContractAddress = '0x0483b0dfc6c78062b9e999a82ffb795925381415';
// 你想要查询的 NFT tokenId
const tokenId = 10;

// 定义合约 ABI，包含 IERC721 的 ownerOf 和 tokenURI 方法
const nftABI = [
    'function ownerOf(uint256 tokenId) view returns (address)',
    'function tokenURI(uint256 tokenId) view returns (string)',
];

// 创建 ethers 合约实例
const provider = new ethers.JsonRpcProvider('https://api.securerpc.com/v1');
const contract = new ethers.Contract(nftContractAddress, nftABI, provider);

// 读取 NFT 的持有人地址
async function getOwnerOfNFT() {
    console.log("开始读取 NFT 持有人地址...");
    try {
        const owner = await contract.ownerOf(tokenId);
        console.log(`Owner of tokenId ${tokenId}: ${owner}`);
    } catch (error) {
        console.error('Error reading ownerOf:', error);
    }
}

// 读取 NFT 的元数据
async function getTokenURI() {
    console.log("开始读取 NFT 元数据...");
    try {
        const uri = await contract.tokenURI(tokenId);
        console.log(`Metadata URI for tokenId ${tokenId}: ${uri}`);
    } catch (error) {
        console.error('Error reading tokenURI:', error);
    }
}

// 执行读取操作
async function readNFT() {
    await getOwnerOfNFT();
    await getTokenURI();
}

readNFT();
