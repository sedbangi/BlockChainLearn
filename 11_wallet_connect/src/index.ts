import { createWalletClient, custom } from 'viem';
import { mainnet } from 'viem/chains';
import { createAppKit } from '@reown/appkit'
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi'


declare global {
    interface Window {
        ethereum: any;
    }
}

const buttonConnectMetaMask = document.getElementById("connectMetaMask");
const buttonConnectViem = document.getElementById("connectViem");

if (buttonConnectMetaMask) {
    buttonConnectMetaMask.addEventListener("click", connectWalletThroughMetaMask);
} else {
    console.error("Button with ID 'connectMetaMask' not found.");
}

if (buttonConnectViem) {
    buttonConnectViem.addEventListener("click", connectWalletThroughViem);
} else {
    console.error("Button with ID 'connectViem' not found.");
}


// 1. connectWalletThroughMetaMask
export async function connectWalletThroughMetaMask() {
    try {
        const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
        console.log(accounts);
        const currentAccount1 = document.getElementById("currentAccount1");
        if(currentAccount1){
            currentAccount1.innerText = 'account: '+ accounts[0];
        }
    } catch (error) {
        console.log(error);
    }
}

// 2. connectWalletThroughViem
export async function connectWalletThroughViem() {
    try {
        const viemClient = createWalletClient({
            chain: mainnet,
            transport: custom(window.ethereum),
        });
        if(viemClient){
            const [account] = await viemClient.requestAddresses()
            console.log(account);
            const currentAccount2 = document.getElementById("currentAccount2");
            if(currentAccount2){
                currentAccount2.innerText = 'account: '+ account;
            }
        }
    } catch (error) {
        console.log(error);
    }
}

// 3. connectWalletThroughWeb3Modal
// 3.1 Get a project ID at https://cloud.reown.com
const projectId = 'b3f89dffdddaae5d7a39f6a9b78b3165'

export const networks = [mainnet]

// 3.2 Set up Wagmi adapter
const wagmiAdapter = new WagmiAdapter({
  projectId,
  networks
})

// 3.3 Configure the metadata
const metadata = {
  name: 'AppKit',
  description: 'AppKit Example',
  url: 'https://example.com', // origin must match your domain & subdomain
  icons: ['https://avatars.githubusercontent.com/u/179229932']
}

// 3.4 Create the modal
const modal = createAppKit({
  adapters: [wagmiAdapter],
  networks: [mainnet],
  metadata,
  projectId,
  features: {
    analytics: true // Optional - defaults to your Cloud configuration
  }
})

// 3.5 Trigger modal programaticaly
const openConnectModalBtn = document.getElementById('open-connect-modal');
const openNetworkModalBtn = document.getElementById('open-network-modal');

if(openConnectModalBtn){
    openConnectModalBtn.addEventListener('click', () => modal.open());
}
if(openNetworkModalBtn){
    openNetworkModalBtn.addEventListener('click', () => modal.open({ view: 'Networks' }));
}

