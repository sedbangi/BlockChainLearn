"use client";
import { useState, useEffect } from "react";
import { formatEther, getContract, parseUnits, Address, Hex, Hash, hexToNumber, pad, slice, toHex, TypedDataDomain} from "viem";

import { wagmi2612Abi } from "./abi_erc2612";
import { tokenBankAbi } from "./abi_tokenbank";
import { permit2Abi } from "./abi_permit2";

import { ConnectWalletClient, ConnectPublicClient } from "./client";

const erc2612Address = "0xAE1E27EB4d39B63A93351c11e81800F183fE13a1"
const tokenBankAddress = "0xa67050df6f731B5669d0a94F51C9425811e9821e"
const permit2Address = "0x45c2013C2172622b5AcD624DD752323712fFB7c8"

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

    const nonce = await permit2?.read.nonces([address]);
    console.log("nonce:" + nonce);

    const expire = BigInt(Math.floor(Date.now() / 1000) + 100_000);
    const amount = parseUnits('1', 18);

    const chainId = await publicClient.getChainId();
    
    const domainData : TypedDataDomain =  {
        name: 'Permit2',
        version: '1',
        chainId: chainId,
        verifyingContract: permit2Address
    }

    const types = {
        Permit2: [
          {name: "token", type: "address"},
          {name: "to", type: "address"},
          {name: "amount", type: "uint256"},
          {name: "expire", type: "uint256"},
          {name: "nonce", type: "uint256"}
        ]
    }

    const message = {
        token: erc2612Address,
        to: tokenBankAddress,
        amount: amount,
        expire: expire,
        nonce: nonce
    }

    const signature = await walletClient.signTypedData({
      account: address as `0x${string}`,
      domain: domainData,
      types: types,
      primaryType: 'Permit2',
      message: message
    })

    console.log(signature);

    const [r, s, v] = [
      slice(signature, 0, 32),
      slice(signature, 32, 64),
      slice(signature, 64, 65),
    ];


    const hash = await tokenBank.write.depositWithPermit2([message,address, hexToNumber(v), r, s], {account: address})

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