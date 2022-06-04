import CollectionConfigInterface from '../lib/CollectionConfigInterface';
import { ethereumTestnet, ethereumMainnet } from '../lib/Networks';
import { openSea } from '../lib/Marketplaces';
import freelistAddresses from './freelist.json';
import goldlistAddresses from './goldlist.json';

const CollectionConfig: CollectionConfigInterface = {
  testnet: ethereumTestnet,
  mainnet: ethereumMainnet,
  // The contract name can be updated using the following command:
  // yarn rename-contract NEW_CONTRACT_NAME
  // Please DO NOT change it manually!
  contractName: 'SheBloomsCollection',
  tokenName: 'She Blooms',
  tokenSymbol: 'SBNFT',
  hiddenMetadataUri: 'ipfs://QmPSsZraxSBSk9eYdUQzVXozJQdw8ztG2KmvMuNzeSG6J9/sheblooms_presale.json',
  maxSupply: 100,
  freelistSale: {
    price: 0.00,
    maxMintAmountPerTx: 1,
  },
  goldlistSale: {
    price: 0.001,
    maxMintAmountPerTx: 1,
  },
  preSale: {
    price: 0.002,
    maxMintAmountPerTx: 2,
  },
  publicSale: {
    price: 0.003,
    maxMintAmountPerTx: 5,
  },
  contractAddress: "0xA3788fCD07A3acf845Fb1771ffc9691BF2136dDd",
  //contractAddress: "0xFFbBbCCC990bf3205467F8Fd3f656aa72F86817a",
  marketplaceIdentifier: 'my-nft-token',
  marketplaceConfig: openSea,
  freelistAddresses: freelistAddresses,
  goldlistAddresses: goldlistAddresses,
  tokenContractName: "SheBloomsToken",
  tokenContractAddress: "0x60A0E01A1AFc273533aE03F8693dce52F8cD0C1b",
  stakingContractName: "SheBloomsStaking",
  stakingContractAddress: "0x00D393033DC6a029e2A4952fBd6960A712E02C2f"
};

export default CollectionConfig;
