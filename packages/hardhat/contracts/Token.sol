// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 initialSupply = 1000 * (10**18);

    constructor() ERC20("Kuic", "KUC") {
        _mint(address(msg.sender), initialSupply); // send to deplouyer, deployer will send to vendor
    }
}
