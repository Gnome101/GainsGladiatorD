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

import {SimpleNFT} from "contracts/SimpleNFT.sol";
import {MockIPGraph} from "@storyprotocol/test/mocks/MockIPGraph.sol";
import {LicensingModule} from "@storyprotocol/core/modules/licensing/LicensingModule.sol";
import {LicenseToken} from "@storyprotocol/core/LicenseToken.sol";
import {IPACombine} from "contracts/IPCombine.sol";

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
contract IPARegistrarTest is Test {
    address internal alice = address(0xa11ce);
    address internal bob = address(0xb0b);

    // For addresses, see https://docs.storyprotocol.xyz/docs/deployed-smart-contracts
    // Protocol Core - IPAssetRegistry
    address internal ipAssetRegistryAddr =
        0x1a9d0d28a0422F26D31Be72Edc6f13ea4371E11B;
    // Protocol Periphery - RegistrationWorkflows
    address internal registrationWorkflowsAddr =
        0x601C24bFA5Ae435162A5dC3cd166280C471d16c8;

    // Protocol Core - LicensingModule
    address internal licensingModuleAddr =
        0xd81fd78f557b457b4350cB95D20b547bFEb4D857;
    // Protocol Core - LicenseToken
    address internal licenseTokenAddr =
        0xc7A302E03cd7A304394B401192bfED872af501BE;
    // Protocol Core - PILicenseTemplate
    address internal pilTemplateAddr =
        0x0752f61E59fD2D39193a74610F1bd9a6Ade2E3f9;

    address internal royaltyModuleAddr =
        0x3C27b2D7d30131D4b58C3584FD7c86e3358744de;

    address internal tokenLicesnse = 0xc7A302E03cd7A304394B401192bfED872af501BE;

    IPAssetRegistry public ipAssetRegistry;
    LicensingModule public immutable LICENSING_MODULE;

    ISPGNFT public spgNft;

    LicenseToken public licenseToken;
    SimpleNFT public simpleNft;
    IPACombine public ipaCombine;
    MockERC20 public sUSDC =
        MockERC20(0x91f6F05B08c16769d3c85867548615d270C42fC7);

    function setUp() public {
        // vm.etch(address(0x1B), address(new MockIPGraph()).code);
        sUSDC.mint(bob, 1000);
        ipAssetRegistry = IPAssetRegistry(ipAssetRegistryAddr);

        ipaCombine = new IPACombine(
            ipAssetRegistryAddr,
            registrationWorkflowsAddr,
            licensingModuleAddr,
            pilTemplateAddr,
            royaltyModuleAddr,
            tokenLicesnse,
            address(sUSDC)
        );
        sUSDC.mint(address(ipaCombine), 1000);

        ipAssetRegistry = IPAssetRegistry(ipAssetRegistryAddr);
        licenseToken = LicenseToken(licenseTokenAddr);

        simpleNft = SimpleNFT(ipaCombine.SIMPLE_NFT());

        console.log("SimpleNFT: %s", address(simpleNft));
        vm.label(address(ipAssetRegistry), "IPAssetRegistry");
        vm.label(address(simpleNft), "SimpleNFT");
        vm.label(
            address(0x000000006551c19487814612e58FE06813775758),
            "ERC6551Registry"
        );
        console.log("IPACombine:: %s", address(ipaCombine));
        console.log("pilTemplate:: %s", address(pilTemplateAddr));
        console.log("lice:: %s", address(licensingModuleAddr));
        console.log("royalty:: %s", address(royaltyModuleAddr));
        console.log(bob, alice);
    }

    //0x3C27b2D7d30131D4b58C3584FD7c86e3358744de
    function test_mintLicenseToken() public {
        uint256 expectedTokenId = simpleNft.nextTokenId();
        address expectedIpId = ipAssetRegistry.ipId(
            block.chainid,
            address(simpleNft),
            expectedTokenId
        );
        vm.prank(bob);
        sUSDC.approve(address(ipaCombine), 1000);
        vm.prank(alice);
        sUSDC.approve(address(ipaCombine), 1000);

        // vm.prank(alice);
        (address ipId, uint256 tokenId) = ipaCombine.mintIp({prompt: "test"});

        vm.prank(bob);
        uint256 startLicenseTokenId = ipaCombine.mintLicenseTokenMin({
            ipId: ipId,
            tokenId: tokenId,
            ltAmount: 2,
            ltRecipient: bob
        });

        console.log(sUSDC.balanceOf(address(ipaCombine.getRoyaltyVault(ipId))));

        assertEq(ipId, expectedIpId, "a");
        assertEq(tokenId, expectedTokenId);
        assertEq(simpleNft.ownerOf(tokenId), address(ipaCombine));
        assertEq(licenseToken.ownerOf(startLicenseTokenId), bob);
        console.log(sUSDC.balanceOf(address(ipaCombine)));

        vm.prank(alice);
        ipaCombine.snapshotAndClaimByTokenBatch(ipId);
    }

    function test_lendAndBorrowLicenseNFT() public {
        // Alice approves sUSDC to IPACombine contract
        vm.prank(bob);
        sUSDC.approve(address(ipaCombine), 10000);

        // Alice mints an IP and license token
        vm.prank(alice);
        (address ipId, uint256 tokenId) = ipaCombine.mintIp("test prompt");

        vm.prank(bob);
        uint256 licenseTokenId = ipaCombine.mintLicenseTokenMin(
            ipId,
            tokenId,
            1,
            bob
        );

        // Alice approves the IPACombine contract to transfer her license token
        vm.prank(bob);
        licenseToken.approve(address(ipaCombine), licenseTokenId);

        // Alice lends the license NFT
        uint256 borrowDuration = 7 days;
        uint256 feePerSecond = 1e16; // 0.01 sUSDC per second
        vm.prank(bob);
        ipaCombine.lendLicenseNFT(licenseTokenId, borrowDuration, feePerSecond);

        // // Bob approves sUSDC to IPACombine contract for collateral
        // uint256 collateralAmount = (100e18 * 150) / 100; // 150% of 100 sUSDC
        // vm.prank(bob);
        // sUSDC.approve(address(ipaCombine), collateralAmount);

        // // Bob borrows the license NFT
        // vm.prank(bob);
        // ipaCombine.borrowLicenseNFT(licenseTokenId);

        // // Check that Bob now owns the license token
        // assertEq(
        //     licenseToken.ownerOf(licenseTokenId),
        //     bob,
        //     "Bob should own the license token"
        // );

        // // Simulate time passing (e.g., 3 days)
        // vm.warp(block.timestamp + 3 days);

        // // Bob returns the license NFT
        // vm.prank(bob);
        // licenseToken.approve(address(ipaCombine), licenseTokenId);

        // vm.prank(bob);
        // ipaCombine.returnLicenseNFT(licenseTokenId);

        // // Check that Alice now owns the license token again
        // assertEq(
        //     licenseToken.ownerOf(licenseTokenId),
        //     alice,
        //     "Alice should own the license token"
        // );

        // // Calculate expected fee
        // uint256 timeBorrowed = 3 days;
        // uint256 expectedFee = timeBorrowed * feePerSecond;
        // if (expectedFee > collateralAmount) {
        //     expectedFee = collateralAmount;
        // }

        // // Check balances
        // uint256 aliceBalance = sUSDC.balanceOf(alice);
        // uint256 bobBalance = sUSDC.balanceOf(bob);

        // assertEq(aliceBalance, expectedFee, "Alice balance incorrect");
        // assertEq(bobBalance, 1000e18 - expectedFee, "Bob balance incorrect");
    }

    // Test claiming collateral when borrower defaults
    function test_claimCollateral() public {
        // Alice approves sUSDC to IPACombine contract
        vm.prank(alice);
        sUSDC.approve(address(ipaCombine), 1000e18);

        // Alice mints an IP and license token
        vm.prank(alice);
        (address ipId, uint256 tokenId) = ipaCombine.mintIp("test prompt");

        vm.prank(alice);
        uint256 licenseTokenId = ipaCombine.mintLicenseTokenMin(
            ipId,
            tokenId,
            1,
            alice
        );

        // Alice approves the IPACombine contract to transfer her license token
        vm.prank(alice);
        licenseToken.approve(address(ipaCombine), licenseTokenId);

        // Alice lends the license NFT
        uint256 borrowDuration = 7 days;
        uint256 feePerSecond = 1e16; // 0.01 sUSDC per second
        vm.prank(alice);
        ipaCombine.lendLicenseNFT(licenseTokenId, borrowDuration, feePerSecond);

        // Bob approves sUSDC to IPACombine contract for collateral
        uint256 collateralAmount = (100e18 * 150) / 100; // 150% of 100 sUSDC
        vm.prank(bob);
        sUSDC.approve(address(ipaCombine), collateralAmount);

        // Bob borrows the license NFT
        vm.prank(bob);
        ipaCombine.borrowLicenseNFT(licenseTokenId);

        // Check that Bob now owns the license token
        assertEq(
            licenseToken.ownerOf(licenseTokenId),
            bob,
            "Bob should own the license token"
        );

        // Simulate time passing beyond borrow duration
        vm.warp(block.timestamp + 8 days);

        // Alice claims the collateral
        vm.prank(alice);
        ipaCombine.claimCollateral(licenseTokenId);

        // Check that Alice has received the collateral
        uint256 aliceBalance = sUSDC.balanceOf(alice);
        assertEq(
            aliceBalance,
            collateralAmount,
            "Alice should receive collateral"
        );

        // The license token remains with Bob since he defaulted
        assertEq(
            licenseToken.ownerOf(licenseTokenId),
            bob,
            "Bob still owns the license token"
        );
    }
} //0x4c8CCd0214D0fd65De6f255b75C0AB3f0fDB8c2d
