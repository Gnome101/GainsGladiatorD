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

    IPAssetRegistry public ipAssetRegistry;
    LicensingModule public immutable LICENSING_MODULE;

    ISPGNFT public spgNft;

    IPARegistrar public ipaRegistrar;
    LicenseToken public licenseToken;
    SimpleNFT public simpleNft;
    IPALicenseToken public ipaLicenseToken;
    IPACombine public ipaCombine;
    MockERC20 public sUSDC =
        MockERC20(0x91f6F05B08c16769d3c85867548615d270C42fC7);

    function setUp() public {
        // vm.etch(address(0x1B), address(new MockIPGraph()).code);
        sUSDC.mint(bob, 1000);
        ipAssetRegistry = IPAssetRegistry(ipAssetRegistryAddr);
        ipaRegistrar = new IPARegistrar(
            ipAssetRegistryAddr,
            registrationWorkflowsAddr,
            licensingModuleAddr,
            pilTemplateAddr
        );
        ipaLicenseToken = new IPALicenseToken(
            ipAssetRegistryAddr,
            licensingModuleAddr,
            pilTemplateAddr
        );

        ipaCombine = new IPACombine(
            ipAssetRegistryAddr,
            registrationWorkflowsAddr,
            licensingModuleAddr,
            pilTemplateAddr,
            royaltyModuleAddr,
            address(sUSDC)
        );
        sUSDC.mint(address(ipaCombine), 1000);

        simpleNft = SimpleNFT(ipaLicenseToken.SIMPLE_NFT());
        spgNft = ISPGNFT(ipaRegistrar.SPG_NFT());

        ipAssetRegistry = IPAssetRegistry(ipAssetRegistryAddr);
        licenseToken = LicenseToken(licenseTokenAddr);
        ipaLicenseToken = new IPALicenseToken(
            ipAssetRegistryAddr,
            licensingModuleAddr,
            pilTemplateAddr
        );
        simpleNft = SimpleNFT(ipaCombine.SIMPLE_NFT());

        console.log("SimpleNFT: %s", address(simpleNft));
        vm.label(address(ipAssetRegistry), "IPAssetRegistry");
        vm.label(address(simpleNft), "SimpleNFT");
        vm.label(address(spgNft), "SPGNFT");
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
} //0x4c8CCd0214D0fd65De6f255b75C0AB3f0fDB8c2d
