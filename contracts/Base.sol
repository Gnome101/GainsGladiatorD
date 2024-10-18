// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Base {
    uint256 public num;

    function setNum(uint256 x) public {
        num = x;
    }
}
