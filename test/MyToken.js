const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyToken", function () {
    let MyToken;
    let myToken;
    let owner;
    let initialSupply;

    // Use 18 decimals for calculations
    const decimals = 18;
    const initialSupplyAmount = 1000000; // 1 Million tokens

    beforeEach(async function () {
        // Get the signers (accounts)
        [owner] = await ethers.getSigners();

        // Calculate the initial supply in the smallest unit (like Wei)
        initialSupply = ethers.utils.parseUnits(initialSupplyAmount.toString(), decimals);

        // Get the ContractFactory for MyToken
        MyToken = await ethers.getContractFactory("MyToken");

        // Deploy the contract, passing the initial supply to the constructor
        myToken = await MyToken.deploy(initialSupply);
        await myToken.waitForDeployment();
    });

    it("Should deploy with the correct name and symbol", async function () {
        expect(await myToken.name()).to.equal("My Token");
        expect(await myToken.symbol()).to.equal("MTK");
    });

    it("Should have the correct decimals", async function () {
        // The default in OpenZeppelin's ERC20 is 18
        expect(await myToken.decimals()).to.equal(decimals);
    });

    it("Should mint the initial supply to the deployer (owner)", async function () {
        const ownerBalance = await myToken.balanceOf(owner.address);
        // Check if the owner's balance matches the initial supply
        expect(ownerBalance).to.equal(initialSupply);
    });

    it("Should have the correct total supply", async function () {
        // The total supply should equal the initial supply minted
        expect(await myToken.totalSupply()).to.equal(initialSupply);
    });
});