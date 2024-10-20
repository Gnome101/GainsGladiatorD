// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "lib/forge-std/src/Script.sol";
import "contracts/IPCombine.sol"; // Adjust the path based on your project structure

contract DeployIPACombine is Script {
    function run() external {
        // Addresses from your Hardhat script
        address ipAssetRegistryAddr = 0x1a9d0d28a0422F26D31Be72Edc6f13ea4371E11B;
        address registrationWorkflowsAddr = 0x601C24bFA5Ae435162A5dC3cd166280C471d16c8;
        address licensingModuleAddr = 0xd81fd78f557b457b4350cB95D20b547bFEb4D857;
        address licenseTokenAddr = 0xc7A302E03cd7A304394B401192bfED872af501BE;
        address pilTemplateAddr = 0x0752f61E59fD2D39193a74610F1bd9a6Ade2E3f9;
        address royaltyModuleAddr = 0x3C27b2D7d30131D4b58C3584FD7c86e3358744de;
        address susdAddr = 0x91f6F05B08c16769d3c85867548615d270C42fC7;

        // Start broadcasting transactions to the network
        vm.startBroadcast();

        // Deploy the IPACombine contract with constructor arguments
        IPACombine ipaCombine = new IPACombine(
            ipAssetRegistryAddr,
            registrationWorkflowsAddr,
            licensingModuleAddr,
            pilTemplateAddr,
            royaltyModuleAddr,
            susdAddr
        );

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log the deployed contract address
        console.log("IPACombine deployed at:", address(ipaCombine));
    }
}
