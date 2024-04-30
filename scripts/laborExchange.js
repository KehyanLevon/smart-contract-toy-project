const hre = require('hardhat');
const ethers = hre.ethers;
const LaborExchangeArtifacts = require('../artifacts/contracts/LaborExchange.sol/LaborExchange.json')

async function main() {
    const [signer] = await ethers.getSigners();
    const contractAddress = '0xe7f1725e7734ce288f8367e1bb143e90bb3f0512';

    const laborExchangeContract = new ethers.Contract(contractAddress, LaborExchangeArtifacts.abi, signer);

    const res = await laborExchangeContract.createTask("1", 1);
    console.log(res);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        console.exit(1)
    });
