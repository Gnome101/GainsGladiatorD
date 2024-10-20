// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import {Test} from "lib/forge-std/src/Test.sol";
import {Base} from "contracts/Base.sol";
import {MockERC20} from "lib/protocol-periphery-v1/test/mocks/MockERC20.sol";

import {IRegistrationWorkflows} from "@storyprotocol/periphery/interfaces/workflows/IRegistrationWorkflows.sol";
import {ISPGNFT} from "@storyprotocol/periphery/interfaces/ISPGNFT.sol";

import {IPAssetRegistry} from "@storyprotocol/core/registries/IPAssetRegistry.sol";

import {IPARegistrar} from "contracts/IPARegistrar.sol";
import {SimpleNFT} from "contracts/SimpleNFT.sol";
import {MockIPGraph} from "@storyprotocol/test/mocks/MockIPGraph.sol";
import {LicensingModule} from "@storyprotocol/core/modules/licensing/LicensingModule.sol";
import {LicenseToken} from "@storyprotocol/core/LicenseToken.sol";
import {IPALicenseToken} from "contracts/IPALicenseToken.sol";
import {IPACombine} from "contracts/IPCombine.sol";

import {Escrow} from "contracts/Escrow.sol";

/*
``
  "DerivativeWorkflows": "0xC022C70DA8c23Ae8e36B3de9039Ed24E4E42a127",
  "GroupingWorkflows": "0x426fF4F7E9Debe565F5Fe6F53334Ad3982295E20",
  "LicenseAttachmentWorkflows": "0x1B95144b62B4566501482e928aa435Dd205fE71B",
  "RegistrationWorkflows": "0xF403fcCAAE6C503D0CC1D25904A0B2cCd5B96C6F",
  "RoyaltyWorkflows": "0xc757921ee0f7c8E935d44BFBDc2602786e0eda6C",
  "SPGNFTBeacon": "0x02324ca8f369abB445F50c4cE79e956e49AC75d8",
  "SPGNFTImpl": "0xC8E4376Da033cE244027B03f9b94dc0d7005D67E"

*/

// Run this test: forge test --fork-url https://testnet.storyrpc.io/ --match-path test/IPARegistrar.t.sol
contract EscrowTest is Test {
    address internal alice = address(0xa11ce);
    address internal bob = address(0xb0b);
    MockERC20 public mockERC20;
    Escrow public escrowChainA;
    Escrow public escrowChainB;

    function setUp() public {
        console.log("Setting up");
        mockERC20 = new MockERC20("MockERC20", "M20");
        mockERC20.mint(address(alice), 1000000000000000000000000);
        mockERC20.mint(address(bob), 1000000000000000000000000);

        escrowChainA = new Escrow(address(mockERC20));
        escrowChainB = new Escrow(address(mockERC20));
    }

    function test_LIT() public {
        uint256 targetId = 0;
        vm.startPrank(alice);
        mockERC20.approve(address(escrowChainA), 10000);
        escrowChainA.createTransfer(targetId, 100, 110, 1000);
        vm.stopPrank();

        vm.startPrank(bob);
        mockERC20.approve(address(escrowChainB), 10000);
        escrowChainB.targetTransfer(targetId, 110, 1000);
        vm.stopPrank();
        Escrow.Transfer memory transferA = escrowChainA.getData(targetId);
        Escrow.Transfer memory transferB = escrowChainB.getData(targetId);

        bool AtoBSwap = escrowChainB.checkSwap(targetId, transferA.amount);
        bool BtoASwap = escrowChainA.checkSwap(targetId, transferB.amount);
        console.log(AtoBSwap, BtoASwap);

        escrowChainA.fulfillTransfer(targetId, transferB.amount, bob);
        escrowChainB.fulfillTransfer(targetId, transferA.amount, alice);
    }

    function test_FuzzLIT(uint256 minAmount, uint256 actualAmount) public {
        vm.assume(minAmount <= 1000);
        vm.assume(actualAmount <= 1000);

        uint256 targetId = 0;
        vm.startPrank(alice);
        mockERC20.approve(address(escrowChainA), 10000);
        escrowChainA.createTransfer(targetId, 100, minAmount, 1000);
        vm.stopPrank();

        vm.startPrank(bob);
        mockERC20.approve(address(escrowChainB), 10000);
        escrowChainB.targetTransfer(targetId, actualAmount, 1000);
        vm.stopPrank();
        Escrow.Transfer memory transferA = escrowChainA.getData(targetId);
        Escrow.Transfer memory transferB = escrowChainB.getData(targetId);

        bool AtoBSwap = escrowChainB.checkSwap(targetId, transferA.amount);
        bool BtoASwap = escrowChainA.checkSwap(targetId, transferB.amount);
        console.log(AtoBSwap, BtoASwap);
        if (actualAmount >= minAmount) {
            assertEq(BtoASwap, true);
        } else {
            assertEq(BtoASwap, false);
        }
        // escrowChainA.fulfillTransfer(targetId, transferB.amount, bob);
        // escrowChainB.fulfillTransfer(targetId, transferA.amount, alice);
    }
}
