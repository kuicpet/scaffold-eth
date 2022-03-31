// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    using SafeMath for uint256;

    event Stake(address staker, uint256 amount);
    event Withdraw(address staker, uint256 amount);

    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool openForWithdraw = false;

    modifier notCompleted() {
        require(
            exampleExternalContract.completed() == false,
            "The external contract is complete"
        );

        _;
    }

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the values or
    // if the `threshold` was not met, allow everyone to call a `withdraw()` function
    function execute() public notCompleted {
        require(
            deadline <= block.timestamp,
            "The deadline has not been met yet."
        );

        if (address(this).balance > threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    // Add a `withdraw(address payable)` function lets users withdraw their balance
    function withdraw(address payable withdrawee) public notCompleted {
        require(openForWithdraw, "Conditions for withdraw not met");
        require(balances[msg.sender] > 0, "There is nothing to withdraw");
        require(
            msg.sender == withdrawee,
            "You cannot withdraw someone elses funds"
        );
        withdrawee.transfer(balances[msg.sender]);

        emit Withdraw(msg.sender, balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }

        return deadline.sub(block.timestamp);
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
