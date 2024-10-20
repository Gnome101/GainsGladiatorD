// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/LLMMarketplace.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "./mocks/MockRegistrationWorkflows.sol";
import "./mocks/MockLicenseAttachmentWorkflows.sol";
import "./mocks/MockRoyaltyPolicyLAP.sol";
import "./mocks/MockIPAccount.sol";

contract LLMMarketplaceTest is Test {
    LLMMarketplace public marketplace;
    ERC20PresetMinterPauser public paymentToken;
    MockRegistrationWorkflows public registrationWorkflows;
    MockLicenseAttachmentWorkflows public licenseAttachmentWorkflows;
    MockRoyaltyPolicyLAP public royaltyPolicy;
    MockIPAccount public mockIPAccount;

    address public owner;
    address public alice;
    address public bob;

    uint256 public constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        // Deploy mock contracts
        paymentToken = new ERC20PresetMinterPauser("Payment Token", "PAY");
        registrationWorkflows = new MockRegistrationWorkflows();
        licenseAttachmentWorkflows = new MockLicenseAttachmentWorkflows();
        royaltyPolicy = new MockRoyaltyPolicyLAP();
        mockIPAccount = new MockIPAccount();

        // Deploy marketplace
        marketplace = new LLMMarketplace(
            address(registrationWorkflows),
            address(licenseAttachmentWorkflows),
            address(royaltyPolicy),
            address(paymentToken),
            address(mockIPAccount)
        );

        // Mint initial tokens to users
        paymentToken.mint(alice, INITIAL_BALANCE);
        paymentToken.mint(bob, INITIAL_BALANCE);

        // Approve marketplace to spend tokens
        vm.prank(alice);
        paymentToken.approve(address(marketplace), type(uint256).max);
        vm.prank(bob);
        paymentToken.approve(address(marketplace), type(uint256).max);
    }

    function test_ListAsset() public {
        vm.prank(alice);
        uint256 tokenId = marketplace.listAsset(
            "https://example.com/code",
            100 ether,
            10
        );

        LLMMarketplace.LLMAsset memory asset = marketplace.getAssetDetails(
            tokenId
        );
        assertEq(asset.codeLink, "https://example.com/code");
        assertEq(asset.price, 100 ether);
        assertEq(asset.creator, alice);
        assertEq(asset.licenseTermsId, 1); // Assuming the mock returns 1
        assertEq(asset.isLicensed, false);
    }

    function test_PurchaseAsset() public {
        vm.prank(alice);
        uint256 tokenId = marketplace.listAsset(
            "https://example.com/code",
            100 ether,
            10
        );

        uint256 bobInitialBalance = paymentToken.balanceOf(bob);
        uint256 aliceInitialBalance = paymentToken.balanceOf(alice);

        vm.prank(bob);
        marketplace.purchaseAsset(tokenId);

        assertEq(paymentToken.balanceOf(bob), bobInitialBalance - 100 ether);
        assertEq(
            paymentToken.balanceOf(alice),
            aliceInitialBalance + 100 ether
        );
    }

    function test_GrantLicense() public {
        vm.prank(alice);
        uint256 tokenId = marketplace.listAsset(
            "https://example.com/code",
            100 ether,
            10
        );

        mockIPAccount.setOwner(tokenId, alice);

        vm.prank(alice);
        marketplace.grantLicense(tokenId, bob);

        assertTrue(marketplace.hasLicense(tokenId, bob));
        LLMMarketplace.LLMAsset memory asset = marketplace.getAssetDetails(
            tokenId
        );
        assertTrue(asset.isLicensed);
    }

    function testFail_ListAssetInvalidRoyalty() public {
        vm.prank(alice);
        marketplace.listAsset("https://example.com/code", 100 ether, 101); // Royalty > 100%
    }

    function testFail_PurchaseNonExistentAsset() public {
        vm.prank(bob);
        marketplace.purchaseAsset(999); // Non-existent token ID
    }

    function testFail_GrantLicenseUnauthorized() public {
        vm.prank(alice);
        uint256 tokenId = marketplace.listAsset(
            "https://example.com/code",
            100 ether,
            10
        );

        mockIPAccount.setOwner(tokenId, alice);

        vm.prank(bob);
        marketplace.grantLicense(tokenId, bob); // Bob is not the owner
    }
}
