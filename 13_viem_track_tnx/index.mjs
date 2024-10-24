import { createPublicClient, http } from 'viem'
import { mainnet } from 'viem/chains'
import { parseAbiItem } from 'viem'

const client = createPublicClient({ 
  chain: mainnet, 
  transport: http("https://rpc.flashbots.net"), 
}) 

const endBlockNumber = await client.getBlockNumber() 
const startBlockNumber = BigInt(endBlockNumber) - BigInt(99)


const filter = await client.createEventFilter({
  address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
  event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
  fromBlock: startBlockNumber, 
  toBlock: endBlockNumber
})
const logs = await client.getFilterLogs({ filter })

for (let index = 0; index < logs.length; index++) {
  const logInstance = logs[index];
  console.log('从',logInstance.args.from,'转账给',logInstance.args.to,' ',logInstance.args.value,'USDC，交易ID:',logInstance.transactionHash)
}
console.log(logs)


