// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";

contract Vendor is Ownable {
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfWei, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amount);

    Token public token;

    constructor(address tokenAddress) {
        token = Token(tokenAddress);
    }

    function buyTokens() external payable {
        require(msg.value > 0, "No ETH was sent.");
        uint256 amountOfTokens = (msg.value * tokensPerEth) / (10**18);
        token.transfer(msg.sender, amountOfTokens);

        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    function sellTokens(uint256 amount) external {
        require(
            amount > 0,
            "Amount of tokens for selling should be greater than 0."
        );
        uint256 weiToSend = (amount * (10**18)) / tokensPerEth;
        bool sent = token.transferFrom(msg.sender, address(this), amount);
        require(sent, "Failed to sell tokens.");
        (sent, ) = msg.sender.call{value: weiToSend}("");
        require(sent, "Failed to sent ether.");

        emit SellTokens(msg.sender, amount);
    }

    // withdrawal of all the Ether in the contract by the Owner
    function withdraw() external onlyOwner {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw Ether.");
    }
}
