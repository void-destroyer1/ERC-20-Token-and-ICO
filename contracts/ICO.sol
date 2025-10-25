// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import Ownable for access control and IERC20 interface to interact with the token
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol"; // Optional: For debugging during development

contract ICO is Ownable {
    // --- State Variables ---

    // The ERC20 token being sold
    IERC20 public token;

    // The rate of token purchase (e.g., how many token units per 1 Wei)
    uint256 public rate;

    // Total amount of Wei raised through the ICO
    uint256 public weiRaised;

    // --- Events ---
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // --- Constructor ---

    /**
     * @dev Constructor, sets the purchase rate and the token contract address.
     * @param _rate The number of token units a buyer gets per wei
     * @param _tokenAddress The address of the ERC20 token being sold
     */
    constructor(uint256 _rate, address _tokenAddress) {
        require(_rate > 0, "ICO: Rate must be greater than zero");
        require(_tokenAddress != address(0), "ICO: Token address cannot be zero");

        rate = _rate;
        token = IERC20(_tokenAddress); // Initialize the IERC20 token instance

        console.log("ICO Contract deployed:");
        console.log("  Token Address:", _tokenAddress);
        console.log("  Rate (tokens per Wei):", _rate);
        console.log("  Owner:", msg.sender);
    }

    // --- Functions (to be added in next commits) ---

    // Function for users to buy tokens will go here (receive() or buyTokens())
    // Function for owner to withdraw funds will go here

}