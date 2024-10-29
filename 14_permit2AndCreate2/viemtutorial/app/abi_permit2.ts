export const permit2Abi =
 [
     {
         "inputs": [],
         "stateMutability": "nonpayable",
         "type": "constructor"
     },
     {
         "inputs": [
             {
                 "internalType": "address",
                 "name": "",
                 "type": "address"
             }
         ],
         "name": "nonces",
         "outputs": [
             {
                 "internalType": "uint256",
                 "name": "",
                 "type": "uint256"
             }
         ],
         "stateMutability": "view",
         "type": "function"
     },
     {
         "inputs": [
             {
                 "components": [
                     {
                         "internalType": "address",
                         "name": "token",
                         "type": "address"
                     },
                     {
                         "internalType": "address",
                         "name": "to",
                         "type": "address"
                     },
                     {
                         "internalType": "uint256",
                         "name": "amount",
                         "type": "uint256"
                     },
                     {
                         "internalType": "uint256",
                         "name": "expire",
                         "type": "uint256"
                     },
                     {
                         "internalType": "uint256",
                         "name": "nonce",
                         "type": "uint256"
                     }
                 ],
                 "internalType": "struct IPermit2.Permit2",
                 "name": "permit2",
                 "type": "tuple"
             },
             {
                 "internalType": "address",
                 "name": "_owner",
                 "type": "address"
             },
             {
                 "internalType": "uint8",
                 "name": "v",
                 "type": "uint8"
             },
             {
                 "internalType": "bytes32",
                 "name": "r",
                 "type": "bytes32"
             },
             {
                 "internalType": "bytes32",
                 "name": "s",
                 "type": "bytes32"
             }
         ],
         "name": "permit2TransferFrom",
         "outputs": [],
         "stateMutability": "nonpayable",
         "type": "function"
     }
 ]as const;

//0xe3fDbDa5E1c5bdb2c6F11C2fc41659f9A3cbc100