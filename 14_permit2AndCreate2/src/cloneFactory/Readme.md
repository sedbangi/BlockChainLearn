







1. user(token launcher) call proxy(factory) to deploy token(with `new`).
2. any user can only call proxy(factory) to mint(only through owner) token.
3. deploy factoryV2 and upgrade proxy
4. factoryV2 change deploy token from `new` to `EIP-1167`

> proxy: openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol