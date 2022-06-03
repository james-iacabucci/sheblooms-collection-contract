import { ethers } from 'hardhat';
import CollectionConfig from '../config/CollectionConfig';
import { TokenContractType } from '../lib/TokenContractProvider';

async function main() {
  const [account] = await ethers.getSigners();

  console.log('Adding Staking Contract as Token Controller...', account.address);


  /*
  const token = await ethers.getContractAt(CollectionConfig.tokenContractName, CollectionConfig.tokenContractAddress!) as TokenContractType;
  console.log('token contract', token);
  try {
    const tx = await token.addController(CollectionConfig.stakingContractAddress!);
  } catch (e) {
    console.error(e)
  }
  */
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
