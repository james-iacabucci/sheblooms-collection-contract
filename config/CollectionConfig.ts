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
  maxSupply: 5,
  freelistSale: {
    price: 0.00,
    mintLimit: 2,
    maxMintAmountPerTx: 1,
  },
  goldlistSale: {
    price: 0.001,
    mintLimit: 2,
    maxMintAmountPerTx: 1,
  },
  preSale: {
    price: 0.002,
    mintLimit: 2,
    maxMintAmountPerTx: 2,
  },
  publicSale: {
    price: 0.003,
    mintLimit: 5,
    maxMintAmountPerTx: 5,
  },
  contractAddress: "0x99f83F4aE5d7734A0EfFC5c6e2112009a5E7C5d2",
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
