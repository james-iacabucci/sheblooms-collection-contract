import CollectionConfig from './CollectionConfig';

// Update the following array if you change the constructor arguments...
const ContractArguments = [
  CollectionConfig.contractAddress,
  CollectionConfig.tokenContractAddress,
] as const;

export default ContractArguments;