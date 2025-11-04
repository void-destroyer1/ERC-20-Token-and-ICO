# **ERC-20 Token & ICO Smart Contract**

![MyToken.sol Deployed](https://res.cloudinary.com/dzwxshzzl/image/upload/v1762277986/MyToken_xlinkz.png)

## **MyToken Contract Address**
0xc6FB7d2f517C3f73f9A575Cb0b2cA7eFc60cBB72

![ICO.sol Deployed](https://res.cloudinary.com/dzwxshzzl/image/upload/v1762277986/ICO_sffxuq.png)

## **ICO Contract Address**
0xbBfF2a7A7d8B11F88A3c87F44199eBe0d16CF017

This project is a complete, working implementation of a standard ERC-20 token and a feature-rich Initial Coin Offering (ICO) smart contract. It is built using Solidity, the Hardhat development environment, and OpenZeppelin Contracts for security and standard compliance.

This is a foundational project for anyone learning DeFi and smart contract development, demonstrating token creation, crowdsale logic, access control, and secure fund management.

## **Features**

### **1\. MyToken.sol (ERC-20 Token)**

* **ERC-20 Standard:** Fully compliant with the ERC-20 standard (name, symbol, decimals, totalSupply, transfer, approve, etc.).  
* **OpenZeppelin Base:** Inherits from OpenZeppelin's secure ERC20.sol contract.  
* **Ownable:** Inherits from Ownable.sol (v5+). The deployer (owner) is set in the constructor.  
* **Initial Supply:** Mints a specified initialSupply of tokens to the deployer's (owner's) address.

### **2\. ICO.sol (ICO Contract)**

* **Token Sales:** Allows users to send native currency (e.g., Ether, CORE) to the contract's receive() function to buy MyToken tokens.  
* **Fixed Rate:** Sells tokens at a fixed rate (e.g., 1000 tokens per 1 Wei).  
* **Sale Cap:** Enforces a maximum amount of native currency (saleCap) that can be raised.  
* **Time Limit:** The sale automatically ends after a specified duration (saleEnd timestamp).  
* **Active Sale Toggle:** The owner can manually pause or unpause the sale using setSaleActive(bool).  
* **Secure Withdrawals:** The owner can securely withdraw all collected funds using the withdraw() function.  
* **Retrieve Unsold Tokens:** After the sale ends, the owner can retrieve any remaining (unsold) tokens from the ICO contract using withdrawUnsoldTokens().  
* **Security:** Implements Ownable for access control and is structured to protect against common re-entrancy attacks.

## **Technology Stack**

* **Blockchain:** Ethereum (EVM-compatible, e.g., Core, Sepolia Testnet)  
* **Smart Contracts:** Solidity (^0.8.18)  
* **Development Framework:** [Hardhat](https://hardhat.org/)  
* **Core Libraries:**  
  * [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) (v5.x) \- For secure, standard implementations of ERC-20 and Ownable.  
  * [Ethers.js](https://docs.ethers.org/) \- For contract deployment and testing.  
* **Testing:**  
  * [Hardhat Network Helpers](https://hardhat.org/hardhat-network-helpers/docs/overview) \- For "time-travel" (e.g., fast-forwarding to saleEnd).  
  * [Chai](https://www.chaijs.com/) \- Assertion library for tests.  
  * [Mocha](https://mochajs.org/) \- Testing framework.

## **Getting Started**

### **Prerequisites**

* [Node.js](https://nodejs.org/) (v18.x or later)  
* npm or yarn  
* [Git](https://git-scm.com/)

### **Installation & Setup**

1. **Clone the repository:**  
   git clone \[https://github.com/your-username/your-repo-name.git\](https://github.com/your-username/your-repo-name.git)  
   cd your-repo-name

2. **Install dependencies:**  
   npm install

3. Create your environment file:  
   Create a file named .env in the project root. This file will store your private key and RPC URLs. It is ignored by git and should never be shared.  
   Use this template:  
   \# Your testnet RPC URL (e.g., from Alchemy, Infura, or QuickNode)  
   SEPOLIA\_RPC\_URL="https"

   \# Your private key from a wallet like MetaMask (use a burner wallet\!)  
   PRIVATE\_KEY="0x..."

4. Configure Hardhat:  
   Open hardhat.config.js and ensure the network (e.g., sepolia) is set up to read from your .env file.

## **Usage**

### **1\. Compile Contracts**

Compile the smart contracts to generate the ABIs and bytecode:

npx hardhat compile

### **2\. Run Tests**

Run the complete test suite. This will deploy fresh contracts to a temporary local network, run all tests (including token purchases and time-traveling past the sale end), and provide a coverage report.

npx hardhat test

You should see all tests passing for both MyToken.js and ICO.js.

### **3\. Deploy Contracts**

Run the deployment script to deploy both MyToken and the ICO contract to your chosen network.

\# Replace 'sepolia' with your target network name from hardhat.config.js  
npx hardhat run scripts/deploy.js \--network sepolia

The script will:

1. Deploy MyToken.sol with an initial supply.  
2. Deploy ICO.sol, passing it the token's address, rate, cap, and duration.  
3. **Crucially:** Transfer a portion of MyToken from your wallet to the ICO contract, so it has tokens to sell.  
4. Log the deployed addresses for both contracts to your console.

### **4\. Interact with the ICO**

After deployment:

1. **Buy Tokens:** Send native currency (e.g., Sepolia ETH) to the deployed **ICO contract address**. The receive() function will automatically execute, and you will receive MyToken tokens in your wallet.  
2. **Withdraw Funds (Owner):** Call the withdraw() function from the owner's wallet to retrieve the collected ETH/CORE.  
3. **End Sale (Owner):** Wait for the duration to pass, or call setSaleActive(false) to pause the sale.  
4. **Retrieve Unsold Tokens (Owner):** After the sale ends, call withdrawUnsoldTokens() to get the leftover tokens back.

## **License**

This project is licensed under the MIT License. See the LICENSE file for details.