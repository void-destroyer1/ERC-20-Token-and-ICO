const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("ICO", function () {
    let MyToken, myToken, ICO, ico;
    let owner, addr1, addr2;
    let initialSupply, tokenRate, saleCap, saleDuration;

    const decimals = 18;
    const initialSupplyAmount = 1000000;
    const saleCapAmount = 10; // Cap: 10 Ether

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        // --- Deploy MyToken ---
        initialSupply = ethers.utils.parseUnits(initialSupplyAmount.toString(), decimals);
        MyToken = await ethers.getContractFactory("MyToken");
        myToken = await MyToken.deploy(initialSupply);
        await myToken.waitForDeployment();

        // --- Deploy ICO ---
        tokenRate = 1000; // 1000 tokens per 1 Wei
        saleCap = ethers.utils.parseEther(saleCapAmount.toString()); // 10 ETH cap
        saleDuration = 7 * 24 * 60 * 60; // 7 days in seconds

        ICO = await ethers.getContractFactory("ICO");
        ico = await ICO.deploy(tokenRate, myToken.address, saleCap, saleDuration);
        await ico.waitForDeployment();

        // --- Transfer tokens to ICO ---
        const icoSupply = ethers.utils.parseUnits("500000", decimals); // 500,000 tokens for sale
        await myToken.transfer(ico.address, icoSupply);
    });

    describe("Deployment", function () {
        it("Should set the correct token address", async function () {
            expect(await ico.token()).to.equal(myToken.address);
        });

        it("Should set the correct rate", async function () {
            expect(await ico.rate()).to.equal(tokenRate);
        });

        it("Should set the correct sale cap", async function () {
            expect(await ico.saleCap()).to.equal(saleCap);
        });

        it("Should set the correct sale end time", async function () {
            const blockNum = await ethers.provider.getBlockNumber();
            const block = await ethers.provider.getBlock(blockNum);
            const deployTimestamp = block.timestamp;
            expect(await ico.saleEnd()).to.equal(deployTimestamp + saleDuration);
        });

        it("Should have the correct token balance", async function () {
            const icoSupply = ethers.utils.parseUnits("500000", decimals);
            expect(await myToken.balanceOf(ico.address)).to.equal(icoSupply);
        });

        it("Should set sale as active", async function () {
            expect(await ico.saleActive()).to.be.true;
        });
    });

    describe("Token Purchase", function () {
        it("Should allow users to buy tokens", async function () {
            const purchaseAmount = ethers.utils.parseEther("1"); // 1 ETH
            const expectedTokens = purchaseAmount.mul(tokenRate);

            await expect(
                addr1.sendTransaction({ to: ico.address, value: purchaseAmount })
            ).to.emit(ico, "TokensPurchased")
             .withArgs(addr1.address, addr1.address, purchaseAmount, expectedTokens);
            
            expect(await myToken.balanceOf(addr1.address)).to.equal(expectedTokens);
            expect(await ico.weiRaised()).to.equal(purchaseAmount);
        });

        it("Should revert if sale is not active", async function () {
            await ico.setSaleActive(false);
            const purchaseAmount = ethers.utils.parseEther("1");
            await expect(
                addr1.sendTransaction({ to: ico.address, value: purchaseAmount })
            ).to.be.revertedWith("ICO: Sale is not active");
        });

        it("Should revert if sale has ended", async function () {
            // Fast forward time
            await time.increaseTo(await ico.saleEnd() + 1);

            const purchaseAmount = ethers.utils.parseEther("1");
            await expect(
                addr1.sendTransaction({ to: ico.address, value: purchaseAmount })
            ).to.be.revertedWith("ICO: Sale has ended");
        });

        it("Should revert if purchase exceeds cap", async function () {
            // Buy up to the cap
            await addr1.sendTransaction({ to: ico.address, value: saleCap });

            // Try to buy 1 more wei
            const tinyPurchase = 1;
            await expect(
                addr2.sendTransaction({ to: ico.address, value: tinyPurchase })
            ).to.be.revertedWith("ICO: Sale cap exceeded");
        });

        it("Should revert if ICO contract has insufficient token balance", async function () {
            // Buy an amount that would require more tokens than the ICO holds
            // ICO holds 500k tokens. Rate is 1000 tokens/wei.
            // 500,000 / 1000 = 500 Wei. Let's try to buy with 501 Wei.
            // This test is tricky with our current high rate. Let's just buy the cap (10 ETH)
            // which requires 10 * 10^18 * 1000 = 10,000 * 10^18 tokens.
            // Our ICO only holds 500,000 * 10^18 tokens. So 1 wei is enough.
            
            const lowRateICO = await ICO.deploy(1, myToken.address, saleCap, saleDuration); // 1 token per wei
            await lowRateICO.waitForDeployment();
            const icoSupply = ethers.utils.parseUnits("100", decimals); // ICO only holds 100 tokens
            await myToken.transfer(lowRateICO.address, icoSupply);

            // Try to buy 101 tokens (by sending 101 wei)
            await expect(
                addr1.sendTransaction({ to: lowRateICO.address, value: 101 })
            ).to.be.revertedWith("ICO: Not enough tokens in contract to sell");
        });
    });

    describe("Withdrawal", function () {
        it("Should allow owner to withdraw funds", async function () {
            const purchaseAmount = ethers.utils.parseEther("2");
            await addr1.sendTransaction({ to: ico.address, value: purchaseAmount });

            const ownerInitialBalance = await ethers.provider.getBalance(owner.address);
            const tx = await ico.withdraw();
            const receipt = await tx.wait();
            const gasUsed = receipt.gasUsed.mul(tx.gasPrice);
            
            const ownerFinalBalance = await ethers.provider.getBalance(owner.address);
            
            expect(await ethers.provider.getBalance(ico.address)).to.equal(0);
            expect(ownerFinalBalance).to.equal(ownerInitialBalance.add(purchaseAmount).sub(gasUsed));
        });

        it("Should revert if non-owner tries to withdraw", async function () {
            await expect(ico.connect(addr1).withdraw()).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should allow owner to withdraw unsold tokens after sale ends", async function () {
            await time.increaseTo(await ico.saleEnd() + 1); // End sale
            
            const initialOwnerBalance = await myToken.balanceOf(owner.address);
            const icoBalance = await myToken.balanceOf(ico.address);
            
            await ico.withdrawUnsoldTokens();

            expect(await myToken.balanceOf(ico.address)).to.equal(0);
            expect(await myToken.balanceOf(owner.address)).to.equal(initialOwnerBalance.add(icoBalance));
        });

        it("Should revert if non-owner tries to withdraw unsold tokens", async function () {
            await time.increaseTo(await ico.saleEnd() + 1);
            await expect(ico.connect(addr1).withdrawUnsoldTokens()).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });
});