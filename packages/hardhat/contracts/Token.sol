// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Kuic", "KUC") {
        _mint(address(msg.sender), 2000 * 10 ** 18); // send to deplouyer, deployer will send to vendor
    }
}