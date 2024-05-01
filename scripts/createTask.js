const { ethers } = require("ethers");
const LaborExchange = require('../artifacts/contracts/LaborExchange.sol/LaborExchange.json');

async function createTask(description, price) {
    const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545");
    
    const signer = provider.getSigner();
    const contract = new ethers.Contract('0x5fbdb2315678afecb367f032d93f642f64180aa3', LaborExchange.abi, signer);

    const tx = await contract.createTask(description, price, { value: ethers.utils.parseEther(String(price)) });
    await tx.wait();
    console.log("Транзакция выполнена успешно. ID транзакции:", tx.hash);
}

async function getPendingTasks() {
    const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545")
    
    const signer = provider.getSigner();
    console.log('signer', signer);
    const contract = new ethers.Contract('0x5fbdb2315678afecb367f032d93f642f64180aa3', LaborExchange.abi, signer);

    const tx = await contract.getPendingTasks();
    console.log("Транзакция выполнена успешно. ID транзакции:", tx);
}

async function getPendingTasksFrom(accauntAddress) {
    const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545")
    const wallet = new ethers.Wallet(accauntAddress, provider);
    const contract = new ethers.Contract('0x5fbdb2315678afecb367f032d93f642f64180aa3', LaborExchange.abi, wallet);
    const tx = await contract.getPendingTasks();
    console.log("Транзакция выполнена успешно. ID транзакции:", tx);
}

// createTask("Описание задачи 2", 1);
// getPendingTasks()
getPendingTasksFrom("0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d")