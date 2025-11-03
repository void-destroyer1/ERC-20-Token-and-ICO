// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import the necessary OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the MyToken contract, inheriting from ERC20 and Ownable
contract MyToken is ERC20, Ownable {
    
    // Constructor function, runs only once when the contract is deployed
    constructor(uint256 initialSupply)
        ERC20("My Token", "MTK") // Calls the ERC20 constructor
        Ownable(msg.sender)      // <-- THIS LINE IS THE FIX
    {
        // Mint the initial supply of tokens to the deployer's address
        // The deployer automatically becomes the 'owner'
        _mint(msg.sender, initialSupply * (10**decimals()));
    }
}