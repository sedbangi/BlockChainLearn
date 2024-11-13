env: anvil --fork https://rpc.ankr.com/eth/d58d3df73575c1439d66f04b0b524730f45de8e22704c0ade9d60f2c9f301c73<br>
relate-contracts:<br>
- RNT(ERC20)
- MyDex
- UniswapV2Factory

business: 
1. admin create RNT and MyDex
2. admin create Pair(weth,) in UniswapV2Factory
3. buyer swap 

//fork mainnet
    //deploy rnt
    //mint rnt to admin
    //deal buyer rnt
    //admin create pair and LP
    //buyer sellETH
    //check
    //buyer buyETH
    //check
    //admin``