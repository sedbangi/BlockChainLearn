const { privateKeyToAccount } = require('viem/accounts');

const domain = {
  name: "Calvin",
  version: "1",
  chainId: 31337,
  verifyingContract: "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
};

const types = {
  Permit: [
    { name: "owner", type: "address" },
    { name: "spender", type: "address" },
    { name: "value", type: "uint256" },
    { name: "nonce", type: "uint256" },
    { name: "deadline", type: "uint256" },
  ],
};

// 创建一个消息，符合 EIP-2612 标准
const message = {
  owner: "0x563690d44c4edB22504D043aEF1339234fFaD046",
  spender: "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
  value: 1, // 1.0 tokens, 调整为合适的小数位
  nonce: 0, // 账户的 nonce，应由智能合约管理
  deadline: Math.floor(Date.now() / 1000) + 60 * 60, // 1小时后的时间戳
};

const account = privateKeyToAccount(
  "0x1b1e3068138f92888a984101b1a1cb7d71532de8cacbe6e903e5e23984977166"
);

async function run() {
  console.log("Address:", account.address);

  const signature = await account.signTypedData({
    domain,
    types,
    primaryType: "Permit",
    message,
  });
  
  console.log("Signature:", signature);

  // 提取 r, s, v
  const r = signature.slice(2, 66);
  const s = signature.slice(66, 130);
  let v = parseInt(signature.slice(130, 132), 16);
  
  // 处理 v 值，如果是 0 或 1，转换为 27 或 28
  if (v < 27) {
      v += 27;
  }
  console.log("r:", r);
  console.log("s:", s);
  console.log("v:", v);
}

run();
