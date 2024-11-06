
proxy addr: 0x40b4189BD0177dA638C4869C591f11e130589EbB<br>
v1 addr: 0xBb1E44B3e02f5c7F88f3C35EfC4aEFe81eCB1BF1<br>
v2 addr: 0x71F6A7AFD5aAAD35d0E295460632Ed132A4dba66<br>
`/script/DeployFactory.sol`<br>

1. user(token launcher) call proxy(factory) to deploy token(with `new`).
2. any user can only call proxy(factory) to mint(only through call the owner of token) token.
3. deploy factoryV2 and **upgrade** **proxy**
4. factoryV2 change deploy token from `new` to **`EIP-1167`** and add some features

> proxy&Upgrade: https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades/blob/main/README.md
> 
> EIP-1167: https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol