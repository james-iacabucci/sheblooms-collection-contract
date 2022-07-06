import { utils } from 'ethers';
import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';
import CollectionConfig from './../config/CollectionConfig';
import NftContractProvider from '../lib/NftContractProvider';

async function main() {
  // Check configuration
  if (CollectionConfig.goldlistAddresses.length < 1) {
    throw '\x1b[31merror\x1b[0m ' + 'The Gold List is empty, please add some addresses to the configuration.';
  }

  // Build the Merkle Tree
  const leafNodes = CollectionConfig.goldlistAddresses.map(addr => keccak256(addr));
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
  const rootHash = '0x' + merkleTree.getRoot().toString('hex');

  // Attach to deployed contract
  const contract = await NftContractProvider.getContract();

  // Update sale price (if needed)
  const goldlistPrice = utils.parseEther(CollectionConfig.goldlistSale.price.toString());
  if (!await (await contract.cost()).eq(goldlistPrice)) {
    console.log(`Updating the token price to ${CollectionConfig.goldlistSale.price} ETH...`);
    await (await contract.setCost(goldlistPrice)).wait();
  }

  // Update max amount per TX (if needed)
  if (!await (await contract.maxMintAmountPerTx()).eq(CollectionConfig.goldlistSale.maxMintAmountPerTx)) {
    console.log(`Updating the max mint amount per TX to ${CollectionConfig.goldlistSale.maxMintAmountPerTx}...`);
    await (await contract.setMaxMintAmountPerTx(CollectionConfig.goldlistSale.maxMintAmountPerTx)).wait();
  }

  // Update mintLimit  (if needed)
  if (!await (await contract.mintLimit()).eq(CollectionConfig.goldlistSale.mintLimit)) {
    console.log(`Updating the mint limit to ${CollectionConfig.goldlistSale.mintLimit}...`);
    await (await contract.setMintLimit(CollectionConfig.goldlistSale.mintLimit)).wait();
  }

  // Update root hash (if changed)
  if ((await contract.goldListMerkleRoot()) !== rootHash) {
    console.log(`Updating the Gold List root hash to: ${rootHash}`);
    await (await contract.setGoldListMerkleRoot(rootHash)).wait();
  }
  
  // Enable Gold List sale (if needed)
  if (!await contract.goldListMintEnabled()) {
    console.log('Enabling Gold List sale...');
    await (await contract.setGoldListMintEnabled(true)).wait();
  }

  console.log('Gold List sale has been enabled!');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
