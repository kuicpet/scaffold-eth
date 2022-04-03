// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";

contract Vendor is Ownable {
    Token public token;
    uint256 public amountOfEth;
    uint256 public amountOfTokens;
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfEth,
        uint256 amountOfTokens
    );

    constructor(address tokenAddress) {
        token = Token(tokenAddress);
    }

    // buyTokens
    function buyTokens() public payable {
        amountOfEth = msg.value;
        amountOfTokens = amountOfEth * tokensPerEth;
        token.transfer(msg.sender, amountOfTokens);
        emit BuyTokens(msg.sender, amountOfEth, amountOfTokens);
    }

    // withDraw ETH
    function withDraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // sellTokens
    function sellTokens(uint256 approvalAmount) public {
        token.transferFrom(msg.sender, address(this), approvalAmount);
        payable(msg.sender).transfer(approvalAmount / tokensPerEth);
        emit SellTokens(
            msg.sender,
            approvalAmount / tokensPerEth,
            approvalAmount
        );
    }
}
