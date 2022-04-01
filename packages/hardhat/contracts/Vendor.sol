// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MyToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    uint256 public constant tokensPerEth = 100;
    MyToken public myToken;

    constructor(address tokenAddress) {
        myToken = MyToken(tokenAddress);
    }

    // create a payable buyTokens() function:
    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH to buy some tokens");

        uint256 tknsToTransfer = (msg.value) * tokensPerEth;

        uint256 vendorBalance = myToken.balanceOf(address(this));
        require(
            vendorBalance >= tknsToTransfer,
            "Vendor contract has not enough tokens in its balance"
        );

        bool sent = myToken.transfer(msg.sender, tknsToTransfer);
        require(sent, "Failed to transfer token to user");
        emit BuyTokens(msg.sender, msg.value, tknsToTransfer);
    }

    // create a sellTokens() function:
    function sellTokens(uint256 amount) public {
        require(amount > 0, "Specify an amount of tokens to sell");

        uint256 ethToSend = amount / tokensPerEth;
        require(
            address(this).balance >= ethToSend,
            "The vendor does not have the liquidity"
        );

        uint256 userBal = myToken.balanceOf(msg.sender);
        require(userBal >= amount, "Cannot sell more coins than owned");

        bool status = myToken.transferFrom(msg.sender, address(this), amount);
        require(status, "Tokens did not transfer to the contract");

        (status, ) = msg.sender.call{value: ethToSend}("");
        require(status, "Failed to send eth for sold tokens");

        emit SellTokens(msg.sender, ethToSend, amount);
    }

    // create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has not balance to withdraw");

        (bool sent, ) = msg.sender.call{value: ownerBalance}("");
        require(sent, "Failed to send user balance back to the owner");

        payable(owner()).transfer(ownerBalance);
    }
}
