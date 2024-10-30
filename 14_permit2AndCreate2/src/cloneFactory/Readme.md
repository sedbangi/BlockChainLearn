proxy addr: 0xBd4A21cF2F47B182E131EeAaDBef2D570f3B3A23
v1 addr: 0x40423383A94bbb0A22FA4E6A8fC0F97E03B482D2
v2 addr: 0x2cfa10ecfF94E0971505a78dF9A91cdE671ed607




1. user(token launcher) call proxy(factory) to deploy token(with `new`).
2. any user can only call proxy(factory) to mint(only through owner) token.
3. deploy factoryV2 and upgrade proxy
4. factoryV2 change deploy token from `new` to `EIP-1167`

> proxy&Upgrade: /OpenZeppelin/openzeppelin-foundry-upgrades