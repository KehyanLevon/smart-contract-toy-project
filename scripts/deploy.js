const hre = require('hardhat');
const ethers = hre.ethers;

async function main() {
    const [signer] = await ethers.getSigners();

    const LaborExchange = await ethers.getContractFactory('LaborExchange', signer)
    await LaborExchange.deploy()
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        console.exit(1)
    });
