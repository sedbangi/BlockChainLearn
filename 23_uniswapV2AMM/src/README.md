env:<br> 
- anvil --fork-url https://rpc.ankr.com/eth/d58d3df73575c1439d66f04b0b524730f45de8e22704c0ade9d60f2c9f301c73<br>
- forge test --rpc-url http://127.0.0.1:8545 -vvvv<br>

relate-contracts:<br>
- RNT(ERC20)
- MyDex
- UniswapV2Router02

business: 
1. admin create RNT and MyDex
2. admin create Pair(wEth,rnt) in MyDex
3. buyer swap (eth,rnt) in MyDex

