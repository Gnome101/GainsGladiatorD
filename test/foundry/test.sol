// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import {Test} from "lib/forge-std/src/Test.sol";
import {Base} from "contracts/Base.sol";

contract SolTest is Test, Base {
    function testNumber(uint256 x) public {
        setNum(x);
        assertEq(num, x);
    }
}
