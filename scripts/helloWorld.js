const hre = require('hardhat');
const ethers = hre.ethers;
const HelloWorldArtifacts = require('../artifacts/contracts/HelloWorld.sol/HelloWorld.json')

async function main() {
    const [signer] = await ethers.getSigners();
    const contractAddress = '0xe7f1725e7734ce288f8367e1bb143e90bb3f0512';

    const helloWorldContract = new ethers.Contract(contractAddress, HelloWorldArtifacts.abi, signer);

    const res = await helloWorldContract.sayHelloWorld();
    console.log(res);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        console.exit(1)
    });
