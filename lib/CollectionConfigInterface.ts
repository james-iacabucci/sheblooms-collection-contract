import NetworkConfigInterface from '../lib/NetworkConfigInterface';
import MarketplaceConfigInterface from '../lib/MarketplaceConfigInterface';

interface SaleConfig {
  price: number;
  mintLimit: number;
  maxMintAmountPerTx: number;
};

export default interface CollectionConfigInterface {
  testnet: NetworkConfigInterface;
  mainnet: NetworkConfigInterface;
  contractName: string;
  tokenName: string;
  tokenSymbol: string;
  hiddenMetadataUri: string;
  maxSupply: number;
  freelistSale: SaleConfig;
  goldlistSale: SaleConfig;
  preSale: SaleConfig;
  publicSale: SaleConfig;
  contractAddress: string|null;
  freelistAddresses: string[];
  goldlistAddresses: string[];
  marketplaceIdentifier: string;
  marketplaceConfig: MarketplaceConfigInterface,
  tokenContractName: string;
  tokenContractAddress: string|null;
  stakingContractName: string;
  stakingContractAddress: string|null;
};