import { writable } from "svelte/store";

import { Web3Provider } from "@ethersproject/providers";
import { Contract } from "@ethersproject/contracts";

import { Contract as MCALLContract, Provider as MCALLProvider, setMulticallAddress } from "ethers-multicall";

import { mandalaAddress, multicallAddress, tonyAddress, NETWORK_ID } from './data.json';

import telarABI from "./abi/TokenAbundancia.sol/MandalaTokenNftAbundancia.json";
import tonyABI from "./abi/TokenAbundancia.sol/TonyRiosNFT.json";

let provider, providerEthcall, telarNFT, tonyNFT, telarNFTMcall, tonyNFTMcall;

export const networkDetails = writable(null);

export const wallet = writable(null);
export const signer = writable(null);
export const wrongNetwork = writable(false);
export const lastToken = writable(0);
export const metamaskInstall = writable(false);

export const contracts = {};

export async function init() {
  // const { ethereum } = window;
  // await window.ethereum.enable()
  if (!provider) {
    provider = new Web3Provider(window.ethereum, "any");
    providerEthcall = new MCALLProvider(provider);
    provider.on("network", (newNetwork, oldNetwork) => {
      if (oldNetwork) {
        setTimeout(() => {
          init();
        }, 0);
      }
    });

    window.ethereum.on("accountsChanged", () => {
      setTimeout(() => {
        init();
      }, 0);
    });
  }
  
  metamaskInstall.set(true);
  const signer = await provider.getSigner();
  const _wallet = await signer.getAddress();
  wallet.set(_wallet);
  metamaskInstall.set(false);


  const _networkDetails = await provider.getNetwork();
  networkDetails.set(_networkDetails);
  // if (_networkDetails.name !== "bnbt") {
  if (_networkDetails.chainId !== 31337) {
    wrongNetwork.set(true);
    return;
  } else {
    wrongNetwork.set(false);
  }
  setMulticallAddress(NETWORK_ID, multicallAddress);
  await providerEthcall.init();
  if (_wallet) {
    telarNFT = new Contract(mandalaAddress, telarABI, signer);
    contracts.telarNFT = telarNFT;
    telarNFTMcall = new MCALLContract(mandalaAddress, telarABI);
        
    tonyNFT = new Contract(tonyAddress, tonyABI, signer);
    tonyNFTMcall = new MCALLContract(tonyAddress, tonyABI);
  }
  
  const _lastToken = await telarNFT.tokenIdCounter();
  lastToken.set(_lastToken.toString());

  
  if (!telarNFT) {
    return;
  }
  telarNFT.on('Transfer', async (from) => {
    if (from === '0x0000000000000000000000000000000000000000'){
      const _lastToken = await telarNFT.tokenIdCounter();
      lastToken.set(_lastToken.toString());
    }
  });
}

export async function login() {
  await window.ethereum.enable();
  await init();
}

export async function changeNetwork() {
  await window.ethereum.request({
    method: "wallet_addEthereumChain",
    params: [
      {
        chainId: `0x${(97).toString(16)}`,
        chainName: "TEST Binance Smart Chain",
        nativeCurrency: {
          name: "BNB",
          symbol: "bnb",
          decimals: 18,
        },
        rpcUrls: ["https://data-seed-prebsc-1-s1.binance.org:8545/"],
        blockExplorerUrls: ["https://testnet.bscscan.com/"],
        // rpcUrls: ['https://bsc-dataseed.binance.org/'],
        // blockExplorerUrls: ['https://bscscan.com/'],
      },
    ],
  });
}

export async function getTokens(from, to) {
  await init();
  let calls = [];
  for (let i = from; i <= to; i++) {
    calls.push(telarNFTMcall.tokenData(i));
  }
  try {
    const ret = await providerEthcall.all(calls);
    return ret;
  } catch(e) {
    console.log(e);
  } 
}


export async function getTokensNetwork(id) {
  await init();
  const net = await contracts.telarNFT.getTokenNetwork(id);
  let calls = net.map(e => telarNFTMcall.tokenData(e));

  try {
    const ret = await providerEthcall.all(calls);
    return ret;
  } catch(e) {
    console.log(e);
  } 
}
