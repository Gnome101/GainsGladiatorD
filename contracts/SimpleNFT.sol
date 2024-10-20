// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SimpleNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    // Mapping to store token prompts
    mapping(uint256 => string) public tokenPrompts;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) Ownable(msg.sender) {}

    function mint(
        address to,
        string memory prompt
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId++;
        tokenPrompts[nextTokenId] = prompt;
        _mint(to, tokenId);
        return tokenId;
    }

    function getPrompt(uint256 tokenId) public view returns (string memory) {
        return tokenPrompts[tokenId];
    }
}
