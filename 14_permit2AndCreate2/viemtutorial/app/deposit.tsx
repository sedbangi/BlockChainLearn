"use client";
import {useEffect, useState} from "react";
import {Address, getContract, Hash, parseUnits, TypedDataDomain} from "viem";

import {wagmi2612Abi} from "./abi_erc2612";
import {tokenBankAbi} from "./abi_tokenbank";
import {permit2Abi} from "./abi_permit2";

import {ConnectPublicClient, ConnectWalletClient} from "./client";

const erc2612Address = "0xcBf4c2b040A68970635C7993D718A9CE2be56103"
const tokenBankAddress = "0x0B4D1E58332C5c0Dab37934bA1012df0c7389B9E"
const permit2Address = "0xf3E1258C869867AeB13421EB6a4B0E7Ff13049F4"

const walletClient = ConnectWalletClient();
const publicClient = ConnectPublicClient();

export default function Deposit() {

	const [address, setAddress] = useState<Address>();
  const [txHash, setTxHash] = useState<Hash>()

  // const [balance, setBalance] = useState<BigInt>(BigInt(0));
  const [tokenBalance, setTokenBalance] = useState<BigInt>(BigInt(0));
  const [allowanced, setAllowanced] = useState<BigInt>(BigInt(0));
  const [deposited, setDeposited] = useState<BigInt>(BigInt(0));
  
  const [token, setToken] = useState<any>(null);
  const [tokenBank, setTokenBank] = useState<any>(null);
  const [permit2, setPermit2] = useState<any>(null);


  useEffect( () => {
    initContract();
    refreshToken();
    refreshDeposited();
  }, [address])

  useEffect(() => {
    ;(async () => {
      if (txHash) {
        console.log("waitForHash:" + txHash);
        await publicClient.waitForTransactionReceipt(
          { hash: txHash }
        )
        
        refreshToken();
        refreshDeposited();
      }
    })()
  }, [txHash])


  const refreshToken = async () => {
    
    const tokenBalance = await token?.read.balanceOf([address]);
    setTokenBalance( tokenBalance );

    const allowanced = await token?.read.allowance([address, permit2Address]);
    setAllowanced(allowanced)
  }

  const refreshDeposited = async () => {
    const deposited = await tokenBank?.read.getBalance([address,erc2612Address]);
    setDeposited(deposited)
  }

  async function initContract() {
    const token = getContract({
      address: erc2612Address,
      abi: wagmi2612Abi,
      publicClient,
      walletClient,
    });

    const tokenBank = getContract({
      address: tokenBankAddress,
      abi: tokenBankAbi,
      publicClient,
      walletClient,
    });

    const permit2 = getContract({
      address: permit2Address,
      abi: permit2Abi,
      publicClient,
      walletClient,
    });

    setToken(token);
    setTokenBank(tokenBank);
    setPermit2(permit2);
  }

  async function handleConnect() {
      const [address] = await walletClient.requestAddresses();
      setAddress(address);

      // const balance = await publicClient.getBalance({ address });
      // setBalance(balance);
      
  }

	// Function to Interact With Smart Contract
  async function handleApprove() {
    try {
      const amount = parseUnits('1', 18) 
      const hash = await token.write.approve([permit2Address, amount], {account: address});
      console.log(`approve hash: ${hash} `);

      setTxHash(hash);

    } catch (error) {
      alert(`Transaction failed: ${error}`);
    }
  }


  async function handleDeposit() {
    try {
      const amount = parseUnits('1', 18) 
      const hash = await tokenBank.write.deposit([address, amount], {account: address})
      console.log(`deposit hash: ${hash} `);

      setTxHash(hash)

    } catch (error) {
      alert(`Transaction failed: ${error}`);
    }
  }


  async function handlePermitDeposit() {
    const uint8Array = new Uint8Array(32); // 假设你已经有一个 32 字节的 Uint8Array
    window.crypto.getRandomValues(uint8Array);
    const nonce = uint8ArrayToBigInt(uint8Array)
    console.log("nonce:" + nonce);

    const deadline = BigInt(Math.floor(Date.now() / 1000) + 100_000);
    const amount = parseUnits('1', 18);

    const chainId = await publicClient.getChainId();
    
    const domainData : TypedDataDomain =  {
        name: "Permit2",
        chainId: chainId,
        verifyingContract: permit2Address
    }

    const types = {
      PermitBatchTransferFrom: [
        {name: "permitted", type: "TokenPermissions[]"},
        {name: "spender", type: "address"},
        {name: "nonce", type: "uint256"},
        {name: "deadline", type: "uint256"}
      ],
      TokenPermissions: [
        {name: "token", type: "address"},
        {name: "amount", type: "uint256"},
      ]
    }

    const message = {
      permitted: [
        {
          token: erc2612Address,
          amount: allowanced
        }
      ],
      spender: tokenBankAddress,
      nonce: nonce,
      deadline: deadline
    }

    const signature = await walletClient.signTypedData({
      account: address as `0x${string}`,
      domain: domainData,
      types: types,
      primaryType: 'PermitBatchTransferFrom',
      message: message
    })

    console.log(signature);

    const transferDetails = [
      {
        to: tokenBankAddress,
        requestedAmount: amount
      }
    ];

    const hash = await tokenBank.write.depositWithPermit2([message,transferDetails,address, signature], {account: address})

    console.log(`deposit hash: ${hash} `);

    await publicClient.getTransactionReceipt({
      hash: hash
    })

    refreshDeposited();
  }


  return (
    <>
     <Status address={address}  tokenBalance={tokenBalance} allowanced={ allowanced }  deposited={deposited} />
      
     <button className="px-8 py-2 rounded-md bg-[#1e2124] flex flex-row items-center justify-center border border-[#1e2124] hover:border hover:border-indigo-600 shadow-md shadow-indigo-500/10"
        onClick={handleConnect}
      >
        <img src="https://upload.wikimedia.org/wikipedia/commons/3/36/MetaMask_Fox.svg" alt="MetaMask Fox" style={{ width: "25px", height: "25px" }} />
        <h1 className="mx-auto">Connect Wallet</h1>
      </button>

      <button
        className="py-2.5 px-2 rounded-md bg-[#1e2124] flex flex-row items-center justify-center border border-[#1e2124] hover:border hover:border-indigo-600 shadow-md shadow-indigo-500/10"
      >
        <h1 className="text-center" onClick={handleApprove}>Approve</h1>
      </button>

      <button
        className="py-2.5 px-2 rounded-md bg-[#1e2124] flex flex-row items-center justify-center border border-[#1e2124] hover:border hover:border-indigo-600 shadow-md shadow-indigo-500/10"
      >
        <h1 className="text-center" onClick={handleDeposit}>Deposit</h1>
      </button>

      <button
        className="py-2.5 px-2 rounded-md bg-[#1e2124] flex flex-row items-center justify-center border border-[#1e2124] hover:border hover:border-indigo-600 shadow-md shadow-indigo-500/10"
      >
        <h1 className="text-center" onClick={handlePermitDeposit}>Permit Deposit</h1>
      </button>

    </>
  );
}

function uint8ArrayToBigInt(uint8Array) {
  let bigInt = BigInt(0);
  for (let i = 0; i < uint8Array.length; i++) {
    bigInt = (bigInt << BigInt(8)) | BigInt(uint8Array[i]);
  }
  return bigInt;
}

function Status({
  address,
  tokenBalance,
  allowanced,
  deposited
}: {
  address: string | null;
  tokenBalance: BigInt;
  allowanced: BigInt;
  deposited: BigInt;
}) {

  if (!address) {
    return (
      <div className="flex items-center">
        <div className="border bg-red-600 border-red-600 rounded-full w-1.5 h-1.5 mr-2"></div>
        <div>Disconnected</div>
      </div>
    );
  }

  return (
    <div className="flex items-center w-full">
      <div className="border bg-green-500 border-green-500 rounded-full w-1.5 h-1.5 mr-2"></div>
      <div className="text-xs md:text-xs">
      {address}
      <br />
        My Token Balance: {tokenBalance?.toString()}
      <br /> 
        My Allowanced: {allowanced?.toString()}
        <br />
        My Deposit: {deposited?.toString()}
      </div>
    </div>
  );
}