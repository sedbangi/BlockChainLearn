import { toHex, encodePacked, keccak256 } from 'viem';
import { MerkleTree } from "merkletreejs";

const users = [
  { address: "0xe1898De73429752070DccEa8514ba1D310821C7C"}, //buyer
  { address: "0xb7D15753D3F76e7C892B63db6b4729f700C01298"},
  { address: "0xf69Ca530Cd4849e3d1329FBEC06787a96a3f9A68"},
  { address: "0xa8532aAa27E9f7c3a96d754674c99F1E2f824800"},
];

  // equal to MerkleDistributor.sol #keccak256(abi.encodePacked(account, amount));
  const elements = users.map((x) =>
    keccak256(encodePacked(["address"], [x.address as `0x${string}`]))
  );


  const merkleTree = new MerkleTree(elements, keccak256, { sort: true });

  const root = merkleTree.getHexRoot();
  console.log("root:" + root);

  const leaf = elements[0];
  const proof = merkleTree.getHexProof(leaf);
  console.log("proof:" +proof);




