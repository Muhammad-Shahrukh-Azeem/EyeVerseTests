// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../node_modules/erc721a/contracts/ERC721A.sol";

contract oldContract is ERC721A {
    constructor() ERC721A("Azuki", "AZUKI") {}

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }
}