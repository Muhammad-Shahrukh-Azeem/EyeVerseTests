// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract GoldenSlags is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("GoldenSlags", "GS") {}
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}