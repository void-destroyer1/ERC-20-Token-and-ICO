// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract ICO is Ownable {
    // --- State Variables ---
    IERC20 public token;
    uint256 public rate; // Tokens per Wei
    uint256 public weiRaised;
    
    // --- Refinements ---
    uint256 public saleCap; // Maximum Wei to be raised
    uint256 public saleEnd; // Timestamp when the sale ends
    bool public saleActive; // Flag to manually start/stop sale

    // --- Events ---
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);

    // --- Constructor ---
    /**
     * @param _rate Tokens per Wei
     * @param _tokenAddress The address of the ERC20 token
     * @param _saleCap Maximum amount of Wei to raise
     * @param _durationInSeconds How long the sale should last from deployment
     */
    constructor(uint256 _rate, address _tokenAddress, uint256 _saleCap, uint256 _durationInSeconds) {
        require(_rate > 0, "ICO: Rate must be greater than zero");
        require(_tokenAddress != address(0), "ICO: Token address cannot be zero");
        require(_saleCap > 0, "ICO: Cap must be greater than zero");
        
        rate = _rate;
        token = IERC20(_tokenAddress);
        saleCap = _saleCap;
        saleEnd = block.timestamp + _durationInSeconds; // Sale ends 'duration' seconds from now
        saleActive = true; // Start the sale immediately
    }

    // --- Functions ---

    /**
     * @dev Fallback function to buy tokens.
     */
    receive() external payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev Main function for users to purchase tokens.
     * @param _beneficiary The address to receive the tokens
     */
    function buyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        require(saleActive, "ICO: Sale is not active");
        require(block.timestamp < saleEnd, "ICO: Sale has ended");
        require(weiAmount > 0, "ICO: Sent Wei must be greater than zero");
        require(weiRaised + weiAmount <= saleCap, "ICO: Sale cap exceeded");

        uint256 tokensToSend = _getTokenAmount(weiAmount);
        require(token.balanceOf(address(this)) >= tokensToSend, "ICO: Not enough tokens in contract to sell");

        weiRaised += weiAmount;
        token.transfer(_beneficiary, tokensToSend);

        emit TokensPurchased(msg.sender, _beneficiary, weiAmount, tokensToSend);
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
        
        (bool sent, ) = owner().call{value: balance}("");
        require(sent, "ICO: Failed to send Ether");

        emit Withdrawal(owner(), balance);
        console.log("Withdrawal by owner %s: %s Wei", owner(), balance);
    }

    /**
     * @dev Allows owner to manually stop or start the sale.
     */
    function setSaleActive(bool _isActive) public onlyOwner {
        saleActive = _isActive;
    }

    /**
     * @dev Allows owner to withdraw any unsold tokens after the sale ends.
     */
    function withdrawUnsoldTokens() public onlyOwner {
        require(block.timestamp >= saleEnd || !saleActive, "ICO: Sale is still active");
        
        uint256 unsoldBalance = token.balanceOf(address(this));
        require(unsoldBalance > 0, "ICO: No unsold tokens to withdraw");

        token.transfer(owner(), unsoldBalance);
    }
}