import { SheBloomsStaking as ContractType } from '../typechain/index';

import { ethers } from 'hardhat';
import CollectionConfig from './../config/CollectionConfig';

export default class StakingContractProvider {
  public static async getContract(): Promise<ContractType> {
    // Check configuration
    if (null === CollectionConfig.stakingContractAddress) {
      throw '\x1b[31merror\x1b[0m ' + 'Please add the Staking contract address to the configuration before running this command.';
    }

    if (await ethers.provider.getCode(CollectionConfig.stakingContractAddress) === '0x') {
      throw '\x1b[31merror\x1b[0m ' + `Can't find a Staking contract deployed to the target address: ${CollectionConfig.stakingContractAddress}`;
    }
    
    return await ethers.getContractAt(CollectionConfig.stakingContractName, CollectionConfig.stakingContractAddress) as ContractType;
  }
};

export type StakingContractType = ContractType;
