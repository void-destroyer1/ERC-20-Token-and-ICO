const hre = require("hardhat");
const { ethers } = hre;

async function main() {
    // --- Deployment Configuration ---
    const tokenInitialSupply = ethers.utils.parseUnits("1000000", 18); // 1,000,000 Tokens
    const icoRate = 1000; // Rate: 1000 MyToken units per 1 Wei (adjust as needed)
    // Amount of tokens to transfer to the ICO contract (e.g., half the supply)
    const icoSupply = ethers.utils.parseUnits("500000", 18);

    // --- Get Signer ---
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    // --- Deploy MyToken Contract ---
    const MyToken = await ethers.getContractFactory("MyToken");
    console.log("Deploying MyToken...");
    const myToken = await MyToken.deploy(tokenInitialSupply);
    await myToken.waitForDeployment();
    console.log(`MyToken deployed to: ${myToken.address}`);

    // --- Deploy ICO Contract ---
    const ICO = await ethers.getContractFactory("ICO");
    console.log("Deploying ICO...");
    // Pass the rate and the deployed MyToken address to the ICO constructor
    const ico = await ICO.deploy(icoRate, myToken.address);
    await ico.waitForDeployment();
    console.log(`ICO deployed to: ${ico.address}`);

    // --- Transfer Tokens to ICO Contract ---
    console.log(`Transferring ${ethers.utils.formatUnits(icoSupply, 18)} MTK to the ICO contract...`);
    // The deployer owns the initial supply, so they call transfer
    const transferTx = await myToken.connect(deployer).transfer(ico.address, icoSupply);
    await transferTx.wait(); // Wait for the transaction to be mined
    console.log(`Tokens transferred successfully!`);
    console.log(`ICO contract MTK balance: ${ethers.utils.formatUnits(await myToken.balanceOf(ico.address), 18)}`);
    console.log(`Deployer MTK balance: ${ethers.utils.formatUnits(await myToken.balanceOf(deployer.address), 18)}`);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});