import { createWalletClient, http } from 'viem';
import { sepolia } from 'viem/chains';
import { secp256k1 } from "ethereum-cryptography/secp256k1";
import { keccak256 } from "ethereum-cryptography/keccak";
import { utf8ToBytes, bytesToHex } from "ethereum-cryptography/utils";
import {rlp,ecsign} from "ethereumjs-util";

// 私钥
const privateKey = Buffer.from('93acc3d06d476fd7d645c7eb79ad282eb3ec58a4c6283dd130aac0117ad97849', 'hex');

// 初始化 viem 客户端
const walletClient = createWalletClient({
  chain: sepolia,
  transport: http('https://relay-sepolia.flashbots.net'),
});



//enablePresale
const transaction1 = {
  nonce: 114,                      // Nonce 值
  gasPrice: BigInt("20000000000"), // 每单位 gas 的价格
  gasLimit: BigInt("21000"),       // Gas 上限
  to: "0x7394287D60ec9d09fD8389e4878eB956548C2ECd",    // 接收方地址
  value: BigInt("0"), // 发送的 ETH 数量（单位为 wei）
  data: "0xa8eac492"  // 交易数据，通常为空
};
const txData1 = [
  transaction1.nonce,                   // Nonce
  transaction1.gasPrice.toString(16),   // Gas Price
  transaction1.gasLimit.toString(16),   // Gas Limit
  transaction1.to,                      // 接收方地址
  transaction1.value.toString(16),      // ETH 数量
  transaction1.data                     // 交易数据
];
const encodedTxData1 = rlp.encode(txData1);
const {v1,r1,s1} = ecsign(keccak256(encodedTxData1),privateKey,11155111)
const signedTxData1 = [...txData1, v1, r1, s1];
const signedTxEncoded1 = rlp.encode(signedTxData1);

//presale
const transaction2 = {
  nonce: 115,                      // Nonce 值
  gasPrice: BigInt("20000000000"), // 每单位 gas 的价格
  gasLimit: BigInt("21000"),       // Gas 上限
  to: "0x7394287D60ec9d09fD8389e4878eB956548C2ECd",    // 接收方地址
  value: BigInt("1000000000000000000"), // 发送的 ETH 数量（单位为 wei）
  //abi-encode
  data: "0xe6ab14340000000000000000000000000000000000000000000000000000000000000064"  // 交易数据，通常为空
};

const txData2 = [
  transaction2.nonce,                   // Nonce
  transaction2.gasPrice.toString(16),   // Gas Price
  transaction2.gasLimit.toString(16),   // Gas Limit
  transaction2.to,                      // 接收方地址
  transaction2.value.toString(16),      // ETH 数量
  transaction2.data                     // 交易数据
];
const encodedTxData2 = rlp.encode(txData2);
const {v2,r2,s2} = ecsign(keccak256(encodedTxData2),privateKey,11155111)
const signedTxData2 = [...txData2, v2, r2, s2];
const signedTxEncoded2 = rlp.encode(signedTxData2);

function bigintToUint8Array(bigint, length = 32) {
  const hex = bigint.toString(16).padStart(length * 2, '0'); // 转为16进制字符串，补全到固定长度
  const bytes = new Uint8Array(length);
  for (let i = 0; i < length; i++) {
    bytes[i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

// 计算签名
async function signMessage(message, privateKey) {
  // 确保 message 是字符串
  const payloadHash = keccak256(utf8ToBytes(message)); // 对 payload 哈希
  const signature = secp256k1.sign(payloadHash, privateKey); // 签名
  const { r, s, recovery } = signature;
  // 将 r 和 s 转为 Uint8Array
  const rBytes = bigintToUint8Array(r);
  const sBytes = bigintToUint8Array(s);
  const v = recovery + 27;

  return `0x${bytesToHex(rBytes)}${bytesToHex(sBytes)}${v.toString(16).padStart(2, '0')}`;
}

// 私钥计算地址
function privateKeyToAddress(privateKey) {
  const publicKey = secp256k1.getPublicKey(privateKey, false).slice(1);
  const address = keccak256(publicKey).slice(-20);
  return `0x${bytesToHex(address)}`;
}

// 发送 bundle
async function sendBundle() {
  const blockNumber = await walletClient.blockNumber;
  const txs = [
    signedTxEncoded1, // 交易1 RLP 编码（用你的数据替换）
    signedTxEncoded2  // 交易2 RLP 编码（用你的数据替换）
  ];

  const payload = {
    jsonrpc: "2.0",
    id: 1,
    method: "eth_sendBundle",
    params: [
      {
        txs: txs,
        blockNumber: `0x${(blockNumber + 10).toString(16)}`,
        minTimestamp: Math.floor(Date.now() / 1000),
        maxTimestamp: Math.floor(Date.now() / 1000) + 60,
      }
    ]
  };

  const signerAddress = privateKeyToAddress(privateKey);
  const signature = await signMessage(JSON.stringify(payload), privateKey);
  console.log('signer',signerAddress);
  console.log('done');
  const response = await fetch('https://relay-sepolia.flashbots.net', {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Flashbots-Signature": `${signerAddress}:${signature}`
    },
    body: JSON.stringify(payload),
  });

  const data = await response.json();
  if (response.ok) {
    console.log("Bundle sent successfully:", data.result);
  } else {
    console.error("Error sending bundle:", data.error);
  }
}

sendBundle();
