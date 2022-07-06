import { utils } from 'ethers';
import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';
import CollectionConfig from './../config/CollectionConfig';
import NftContractProvider from '../lib/NftContractProvider';

async function main() {
  // Check configuration
  if (CollectionConfig.freelistAddresses.length < 1) {
    throw '\x1b[31merror\x1b[0m ' + 'The Free List is empty, please add some addresses to the configuration.';
  }

  // Build the Merkle Tree
  const leafNodes = CollectionConfig.freelistAddresses.map(addr => keccak256(addr));
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
  const rootHash = '0x' + merkleTree.getRoot().toString('hex');

  // Attach to deployed contract
  const contract = await NftContractProvider.getContract();

  // Update sale price (if needed)
  const freelistPrice = utils.parseEther(CollectionConfig.freelistSale.price.toString());
  if (!await (await contract.cost()).eq(freelistPrice)) {
    console.log(`Updating the token price to ${CollectionConfig.freelistSale.price} ETH...`);
    await (await contract.setCost(freelistPrice)).wait();
  }

  // Update max amount per TX (if needed)
  if (!await (await contract.maxMintAmountPerTx()).eq(CollectionConfig.freelistSale.maxMintAmountPerTx)) {
    console.log(`Updating the max mint amount per TX to ${CollectionConfig.freelistSale.maxMintAmountPerTx}...`);
    await (await contract.setMaxMintAmountPerTx(CollectionConfig.freelistSale.maxMintAmountPerTx)).wait();
  }

  // Update mintLimit  (if needed)
  if (!await (await contract.mintLimit()).eq(CollectionConfig.freelistSale.mintLimit)) {
    console.log(`Updating the mint limit to ${CollectionConfig.freelistSale.mintLimit}...`);
    await (await contract.setMintLimit(CollectionConfig.freelistSale.mintLimit)).wait();
  }

  // Update root hash (if changed)
  if ((await contract.freeListMerkleRoot()) !== rootHash) {
    console.log(`Updating the Free List root hash to: ${rootHash}`);
    await (await contract.setFreeListMerkleRoot(rootHash)).wait();
  }
  
  // Enable Free List sale (if needed)
  if (!await contract.freeListMintEnabled()) {
    console.log('Enabling Free List sale...');
    await (await contract.setFreeListMintEnabled(true)).wait();
  }

  console.log('Free List sale has been enabled!');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
