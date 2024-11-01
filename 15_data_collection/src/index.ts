import { createPublicClient, http, Log, parseAbiItem } from 'viem'
import { mainnet } from 'viem/chains'

const publicClient = createPublicClient({
    chain: mainnet,
    transport: http('https://rpc.particle.network/evm-chain?chainId=1&projectUuid=e1ee773c-e623-44f3-9de2-aa6e13b1f281&projectKey=cY5KUqZtaW1pNh5kS0ToMYR0tNtALLSYt8V09QNG')
});

const blockEle = document.getElementById('block')
const usdtEle = document.getElementById('usdt')
// // 监听最新的区块
const unwatchBlock = publicClient.watchBlocks({
    onBlock: (block) => {
        console.log('new block:', block.number, '(', block.hash, ')');
        blockEle.innerText = ('new block:'+ block.number + '(' + block.hash + ')')
    }
});

const unwatch = publicClient.watchEvent({
    address: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'), 
    onLogs: (logs) => {
        logs.forEach((log) => {
          try {
            const from = `0x${log.topics[1].slice(26)}`;  // 提取地址
            const to = `0x${log.topics[2].slice(26)}`;    // 提取地址

            const rawValue = BigInt(log.data); // 转换为数值表示
            const integerPart = (rawValue / BigInt(10 ** 6)).toString();
            const decimalPart = (rawValue % BigInt(10 ** 6)).toString().padStart(6, '0'); // 确保小数部分有 6 位
            const value = `${integerPart}.${decimalPart}`; // 拼接整数部分和小数部分            console.log(`At block ${log.blockNumber} (${log.blockHash}): Transfer ${value} usdt from ${from} to ${to}`);
            
            usdtEle.innerHTML += `At block ${log.blockNumber} (${log.blockHash}): Transfer ${value} usdt from ${from} to ${to}</br>`;
          } catch (error) {
            console.log(error);
          }
        });
    }
})
