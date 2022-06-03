import NftContractProvider from '../lib/NftContractProvider';

async function main() {
  // Attach to deployed contract
  const contract = await NftContractProvider.getContract();
  
  // Disable Gold List sale (if needed)
  if (await contract.goldListMintEnabled()) {
    console.log('Disabling Gold List sale...');

    await (await contract.setGoldListMintEnabled(false)).wait();
  }

  console.log('The Gold List sale has been disabled!');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
