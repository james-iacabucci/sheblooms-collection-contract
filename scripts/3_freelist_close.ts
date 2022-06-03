import NftContractProvider from '../lib/NftContractProvider';

async function main() {
  // Attach to deployed contract
  const contract = await NftContractProvider.getContract();
  
  // Disable Free List sale (if needed)
  if (await contract.freeListMintEnabled()) {
    console.log('Disabling Free List sale...');

    await (await contract.setFreeListMintEnabled(false)).wait();
  }

  console.log('The Free List sale has been disabled!');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
