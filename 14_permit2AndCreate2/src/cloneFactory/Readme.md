
proxy addr: 0x2bF95Ed94C86eb4F33f98cfC0907Fd640ae5672d<br>
v1 addr: 0x647d02Db91616e6F0b6a15CBA51e71e5f08A537a<br>
v2 addr: 0x2158E643ABBAe9383954e59E02D479Ef1D96E785<br>
`/script/DeployFactory.sol`<br>

1. user(token minter) call proxy(factory) to deploy token(with `new`).
2. any user can only call proxy(factory) to mint(only through call the owner of token) token.
3. deploy factoryV2 and **upgrade** **proxy**
4. factoryV2 change deploy token from `new` to **`EIP-1167`** and add some features

> proxy&Upgrade: https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades/blob/main/README.md
> 
> EIP-1167: https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol