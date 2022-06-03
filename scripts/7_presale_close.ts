import NftContractProvider from '../lib/NftContractProvider';

async function main() {
  // Attach to deployed contract
  const contract = await NftContractProvider.getContract();
  
  // Pause the contract (if needed)
  if (!await contract.paused()) {
    console.log('Pausing the contract...');

    await (await contract.setPaused(true)).wait();
  }

  // Disable PreSale  (if needed)
  if (await contract.preSaleMintEnabled()) {
    console.log('Disabling Pre Sale...');

    await (await contract.setPreSaleMintEnabled(false)).wait();
  }

  console.log('Pre-sale is now closed!');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
