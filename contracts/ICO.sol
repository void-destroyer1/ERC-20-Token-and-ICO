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
    event Withdrawal(address indexed owner, uint256 amount); // Added event

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
     */
    receive() external payable {
        uint256 weiAmount = msg.value;
        require(weiAmount > 0, "ICO: Sent Wei must be greater than zero");

        uint256 tokensToSend = _getTokenAmount(weiAmount);
        require(token.balanceOf(address(this)) >= tokensToSend, "ICO: Not enough tokens in contract to sell");

        weiRaised += weiAmount;
        token.transfer(msg.sender, tokensToSend);

        emit TokensPurchased(msg.sender, msg.sender, weiAmount, tokensToSend);
        console.log("Tokens purchased by %s: %s tokens for %s Wei", msg.sender, tokensToSend, weiAmount);
    }

    /**
     * @dev Internal function to calculate token amount.
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount * rate;
    }

    // --- Owner Functions ---

    /**
     * @dev Allows the owner to withdraw the collected Ether/CORE.
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "ICO: No funds to withdraw");

        // Transfer the entire contract balance to the owner
        // Using .call() is the recommended secure way to send Ether
        (bool sent, ) = owner().call{value: balance}("");
        require(sent, "ICO: Failed to send Ether");

        emit Withdrawal(owner(), balance); // Emit the event
        console.log("Withdrawal by owner %s: %s Wei", owner(), balance);
    }
}