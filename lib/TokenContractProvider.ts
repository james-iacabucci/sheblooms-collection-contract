// The name below ("SheBloomsCollection") should match the name of your Solidity contract.
// It can be updated using the following command:
// yarn rename-contract NEW_CONTRACT_NAME
// Please DO NOT change it manually!
import { SheBloomsToken as ContractType } from '../typechain/index';

import { ethers } from 'hardhat';
import CollectionConfig from './../config/CollectionConfig';

export default class TokenContractProvider {
  public static async getContract(): Promise<ContractType> {
    // Check configuration
    if (null === CollectionConfig.tokenContractAddress) {
      throw '\x1b[31merror\x1b[0m ' + 'Please add the Token contract address to the configuration before running this command.';
    }

    if (await ethers.provider.getCode(CollectionConfig.tokenContractAddress) === '0x') {
      throw '\x1b[31merror\x1b[0m ' + `Can't find a Token contract deployed to the target address: ${CollectionConfig.tokenContractAddress}`;
    }
    
    return await ethers.getContractAt(CollectionConfig.tokenContractName, CollectionConfig.tokenContractAddress) as ContractType;
  }
};

export type TokenContractType = ContractType;
