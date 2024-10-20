// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {IPAssetRegistry} from "@storyprotocol/core/registries/IPAssetRegistry.sol";
import {LicensingModule} from "@storyprotocol/core/modules/licensing/LicensingModule.sol";
import {RoyaltyModule} from "@storyprotocol/core/modules/royalty/RoyaltyModule.sol";
import {PILicenseTemplate} from "@storyprotocol/core/modules/licensing/PILicenseTemplate.sol";
import {PILTerms} from "node_modules/@story-protocol/protocol-core/contracts/modules/licensing/PILicenseTemplate.sol";
import {ISPGNFT} from "@storyprotocol/periphery/interfaces/ISPGNFT.sol";
import {RegistrationWorkflows} from "@storyprotocol/periphery/workflows/RegistrationWorkflows.sol";
import {WorkflowStructs} from "@storyprotocol/periphery/lib/WorkflowStructs.sol";
import {MockERC20} from "lib/protocol-periphery-v1/test/mocks/MockERC20.sol";

import {SimpleNFT} from "./SimpleNFT.sol";

/// @notice Mint a License Token from Programmable IP License Terms attached to an IP Account.
contract IPACombine {
    IPAssetRegistry public immutable IP_ASSET_REGISTRY;
    LicensingModule public immutable LICENSING_MODULE;
    PILicenseTemplate public immutable PIL_TEMPLATE;
    SimpleNFT public immutable SIMPLE_NFT;
    ISPGNFT public immutable SPG_NFT;
    RegistrationWorkflows public immutable REGISTRATION_WORKFLOWS;
    RoyaltyModule public immutable ROYALTY_MODULE;
    MockERC20 public sUSDC =
        MockERC20(0x91f6F05B08c16769d3c85867548615d270C42fC7);

    uint256 pilId;
    address immutable CURRENCY;

    constructor(
        address ipAssetRegistry,
        address registrationWorkflows,
        address licensingModule,
        address pilTemplate,
        address royaltyModule,
        address currency
    ) {
        CURRENCY = currency;
        IP_ASSET_REGISTRY = IPAssetRegistry(ipAssetRegistry);
        LICENSING_MODULE = LicensingModule(licensingModule);
        ROYALTY_MODULE = RoyaltyModule(royaltyModule);
        PIL_TEMPLATE = PILicenseTemplate(pilTemplate);
        // Create a new Simple NFT collection
        SIMPLE_NFT = new SimpleNFT("Simple IP NFT", "SIM");
        REGISTRATION_WORKFLOWS = RegistrationWorkflows(registrationWorkflows);

        PILTerms memory terms = PILTerms(
            true, // transferable - The prompt licenses can be transferred between users.
            0x4074CEC2B3427f983D14d0C5E962a06B7162Ab92, // royaltyPolicy - Address of the royalty policy contract.
            100, // defaultMintingFee - A default fee (in wei or a specific token) for minting new license tokens for prompts.
            block.timestamp + 365 days, // expiration - License expiration date set to one year from now.
            true, // commercialUse - Allows commercial use of the LLM prompts.
            true, // commercialAttribution - Attribution is required for commercial use of the LLM prompts.
            address(0), // commercializerChecker - Address of a contract that checks for commercial use compliance.
            "", // commercializerCheckerData - No additional data is required for compliance check.
            300, // commercialRevShare - 3% revenue share for commercial use of the prompts.
            1000000, // commercialRevCeiling - Maximum revenue share capped at 1,000,000 wei.
            true, // derivativesAllowed - Derivative works from the prompts are allowed (e.g., modifying the prompt).
            true, // derivativesAttribution - Attribution is required for derivative works.
            false, // derivativesApproval - No need for explicit approval to create derivatives.
            true, // derivativesReciprocal - Any derivative work created must allow further derivatives.
            500000, // derivativeRevCeiling - Maximum revenue share from derivatives capped at 500,000 wei.
            CURRENCY, // currency - The address of the token (e.g., a stablecoin or native token) used for payments.
            "https://example.com/prompt-terms" // uri - A URL pointing to the detailed terms of use for the LLM prompt.
        );
        sUSDC.approve(address(ROYALTY_MODULE), type(uint256).max);
        pilId = PIL_TEMPLATE.registerLicenseTerms(terms);
    }

    function mintIp(
        string memory prompt
    ) external returns (address ipId, uint256 tokenId) {
        tokenId = SIMPLE_NFT.mint(address(this), prompt);
        ipId = IP_ASSET_REGISTRY.register(
            block.chainid,
            address(SIMPLE_NFT),
            tokenId
        );
    }

    function mintLicenseTokenMin(
        address ipId,
        uint256 tokenId,
        uint256 ltAmount,
        address ltRecipient
    ) external returns (uint256 startLicenseTokenId) {
        // (ipId, tokenId) = spgMintIp();

        // Then, attach a selection of license terms from the PILicenseTemplate, which is already registered.
        // Note that licenseTermsId = 2 is a Non-Commercial Social Remixing (NSCR) license.
        // Read more about NSCR: https://docs.storyprotocol.xyz/docs/pil-flavors#flavor-1-non-commercial-social-remixing
        // LICENSING_MODULE.attachLicenseTerms(ipId, address(PIL_TEMPLATE), 2);

        // Then, mint a License Token from the attached license terms.
        // Note that the License Token is minted to the ltRecipient.
        startLicenseTokenId = LICENSING_MODULE.mintLicenseTokens({
            licensorIpId: ipId,
            licenseTemplate: address(PIL_TEMPLATE),
            licenseTermsId: pilId,
            amount: ltAmount,
            receiver: ltRecipient,
            royaltyContext: "" // for PIL, royaltyContext is empty string
        });

        // Finally, transfer the NFT to the msg.sender.
        // SIMPLE_NFT.transferFrom(address(this), msg.sender, tokenId);
    }

    function mintLicenseToken(
        uint256 ltAmount,
        address ltRecipient,
        string memory prompt
    )
        external
        returns (address ipId, uint256 tokenId, uint256 startLicenseTokenId)
    {
        // First, mint an NFT and register it as an IP Account.
        // Note that first we mint the NFT to this contract for ease of attaching license terms.
        // We will transfer the NFT to the msg.sender at last.

        tokenId = SIMPLE_NFT.mint(address(this), prompt);
        ipId = IP_ASSET_REGISTRY.register(
            block.chainid,
            address(SIMPLE_NFT),
            tokenId
        );
        // (ipId, tokenId) = spgMintIp();

        // Then, attach a selection of license terms from the PILicenseTemplate, which is already registered.
        // Note that licenseTermsId = 2 is a Non-Commercial Social Remixing (NSCR) license.
        // Read more about NSCR: https://docs.storyprotocol.xyz/docs/pil-flavors#flavor-1-non-commercial-social-remixing
        // LICENSING_MODULE.attachLicenseTerms(ipId, address(PIL_TEMPLATE), 2);

        // Then, mint a License Token from the attached license terms.
        // Note that the License Token is minted to the ltRecipient.
        startLicenseTokenId = LICENSING_MODULE.mintLicenseTokens({
            licensorIpId: ipId,
            licenseTemplate: address(PIL_TEMPLATE),
            licenseTermsId: pilId,
            amount: ltAmount,
            receiver: ltRecipient,
            royaltyContext: "" // for PIL, royaltyContext is empty string
        });

        // Finally, transfer the NFT to the msg.sender.
        // SIMPLE_NFT.transferFrom(address(this), msg.sender, tokenId);
    }

    function snapshotAndClaimByTokenBatch(
        address ipId
    ) external returns (uint256 snapshotId, uint256[] memory amountsClaimed) {
        // // Gets the IP's royalty vault
        // IIpRoyaltyVault ipRoyaltyVault = IIpRoyaltyVault(
        //     ROYALTY_MODULE.ipRoyaltyVaults(ipId)
        // );
        // // Claims revenue for each specified currency token from the latest snapshot
        // snapshotId = ipRoyaltyVault.snapshot();
        // address[] memory currencyTokens = new address[](1);
        // currencyTokens[0] = CURRENCY;
        // amountsClaimed = ipRoyaltyVault.claimRevenueOnBehalfByTokenBatch({
        //     snapshotId: snapshotId,
        //     tokenList: currencyTokens,
        //     claimer
        // });
    }

    function claimEarnings(address ipId) external {
        // Gets the IP's royalty vault
        sUSDC.mint(msg.sender, 1000); // Using this in place of the vault because of versions
    }

    function getRoyaltyVault(address ipId) external view returns (address) {
        return ROYALTY_MODULE.ipRoyaltyVaults(ipId);
    }
}
//make a custom template -> add uniswap -> premint tokens -> when a user purchases a license they get it and the price increases ->
//maybe let user's borrow from the pool as well so they could rent a license.
