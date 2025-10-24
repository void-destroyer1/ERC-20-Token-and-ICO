// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; // Use a Solidity version compatible with OpenZeppelin

// Import the necessary OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the MyToken contract, inheriting from ERC20 and Ownable
contract MyToken is ERC20, Ownable {
    // Constructor function, runs only once when the contract is deployed
    constructor(uint256 initialSupply) ERC20("My Token", "MTK") {
        // Mint the initial supply of tokens to the deployer's address
        // The deployer automatically becomes the 'owner' due to Ownable
        _mint(msg.sender, initialSupply * (10**decimals()));
    }
}