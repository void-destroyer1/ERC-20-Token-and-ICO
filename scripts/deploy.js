// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { ethers } = hre; // Optional: Import ethers directly for convenience

async function main() {
    // --- Deployment Configuration ---
    const initialSupply = ethers.utils.parseUnits("1000000", 18); // 1,000,000 Tokens with 18 decimals

    // --- Deploy MyToken Contract ---
    const MyToken = await hre.ethers.getContractFactory("MyToken");
    console.log("Deploying MyToken...");

    const myToken = await MyToken.deploy(initialSupply);

    // In Hardhat versions >= 2.10.0, use waitForDeployment()
    await myToken.waitForDeployment();
    // For older versions, you might use: await myToken.deployed();

    console.log(`MyToken deployed to: ${myToken.address}`);
    console.log(`Initial supply: ${ethers.utils.formatUnits(initialSupply, 18)} MTK`);

    // --- (ICO Deployment will be added later) ---
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});