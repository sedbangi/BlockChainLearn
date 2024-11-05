import { createPublicClient, http, keccak256, hexToBigInt, slice, numberToHex } from 'viem';
import { anvil } from 'viem/chains'

const client = createPublicClient({
    chain: anvil,
    transport: http(),
});

const contractAddress = '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707';
const baseSlot = 0;

//get arrayLength
const arrayLength = await client.getStorageAt({
    address: contractAddress,
    slot: baseSlot
})

//get startSlot
const startSlot = hexToBigInt(keccak256(numberToHex(0, { size: 32 })))

for (let index = 0; index < arrayLength; index++) {
    //element start Slot
    const eleStartSlot = startSlot +(BigInt(index)*BigInt(2)) ;
    //one lock ele store in two slot
    const slot1 = await client.getStorageAt({
        address: contractAddress,
        slot: eleStartSlot
    })
    const solt2 = await client.getStorageAt({
        address: contractAddress,
        slot: eleStartSlot+BigInt(1)
    })
    //locks[0]: user:…… ,startTime:……,amount:……
    console.log(`Locks[${index}]: user:`,slice(slot1, 12, 32),',startTime:',hexToBigInt(slice(slot1, 0, 12)),',amount:',hexToBigInt(solt2))
}

