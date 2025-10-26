// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol"; // Optional: For debugging

contract ICO is Ownable {
    // --- State Variables ---
    IERC20 public token;
    uint256 public rate;
    uint256 public weiRaised;

    // --- Events ---
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // --- Constructor ---
    constructor(uint256 _rate, address _tokenAddress) {
        require(_rate > 0, "ICO: Rate must be greater than zero");
        require(_tokenAddress != address(0), "ICO: Token address cannot be zero");

        rate = _rate;
        token = IERC20(_tokenAddress);

        console.log("ICO Contract deployed:");
        console.log("  Token Address:", _tokenAddress);
        console.log("  Rate (tokens per Wei):", _rate);
        console.log("  Owner:", msg.sender);
    }

    // --- Functions ---

    /**
     * @dev Fallback function called when Ether is sent to the contract.
     * Allows users to purchase tokens by sending native currency.
     */
    receive() external payable {
        uint256 weiAmount = msg.value;
        require(weiAmount > 0, "ICO: Sent Wei must be greater than zero");

        // Calculate the amount of tokens to send
        uint256 tokensToSend = _getTokenAmount(weiAmount);

        // Require that the ICO contract has enough tokens to sell
        require(token.balanceOf(address(this)) >= tokensToSend, "ICO: Not enough tokens in contract to sell");

        // Increment the total wei raised
        weiRaised += weiAmount;

        // Transfer the tokens to the buyer (msg.sender)
        // IMPORTANT: The ICO contract MUST hold the tokens being sold!
        // The owner needs to transfer the tokens to this ICO contract address after deployment.
        token.transfer(msg.sender, tokensToSend);

        // Emit the event
        emit TokensPurchased(msg.sender, msg.sender, weiAmount, tokensToSend);

        console.log("Tokens purchased by %s: %s tokens for %s Wei", msg.sender, tokensToSend, weiAmount);
    }

    /**
     * @dev Internal function to calculate token amount based on wei amount and rate.
     * @param _weiAmount Amount of wei sent by the buyer.
     * @return amount of tokens to be transferred.
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        // Note: Assumes token has standard 18 decimals. Adjust if different.
        // Calculation: weiAmount * rate
        return _weiAmount * rate;
    }

    // --- Owner Functions (Withdrawal to be added next) ---

}