import { ethers } from 'hardhat';
import CollectionConfig from '../config/CollectionConfig';
import { TokenContractType } from '../lib/TokenContractProvider';
import { StakingContractType } from '../lib/StakingContractProvider';
import ContractArguments from './../config/StakingContractArguments';

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  console.log('Deploying Staking Contract...');

  // We get the contract to deploy
  const Contract = await ethers.getContractFactory(CollectionConfig.stakingContractName);
  const contract = await Contract.deploy(...ContractArguments) as StakingContractType;

  await contract.deployed();

  console.log(`${CollectionConfig.stakingContractName} contract deployed to: ${contract.address}`);

  //const token = await ethers.getContractAt(CollectionConfig.tokenContractName, CollectionConfig.tokenContractAddress!) as TokenContractType;
  //const tx = await token.addController(contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
