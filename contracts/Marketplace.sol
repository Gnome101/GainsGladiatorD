// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@storyprotocol/core/interfaces/IIPAccount.sol";
// import "lib/protocol-periphery-v1/contracts/interfaces/workflows/IRegistrationWorkflows.sol";
// import "lib/protocol-periphery-v1/contracts/interfaces/workflows/ILicenseAttachmentWorkflows.sol";
// import "lib/protocol-periphery-v1/contracts/interfaces/workflows/IRoyaltyWorkflows.sol";

// contract LLMMarketplace is Ownable {
//     IRegistrationWorkflows public registrationWorkflows;
//     ILicenseAttachmentWorkflows public licenseAttachmentWorkflows;
//     IRoyaltyPolicyLAP public royaltyPolicy;
//     IERC20 public paymentToken;
//     address public nftContract;

//     struct LLMAsset {
//         string codeLink;
//         uint256 price;
//         address payable creator;
//         uint256 licenseTermsId;
//         bool isLicensed;
//     }

//     mapping(uint256 => LLMAsset) public llmAssets;

//     event AssetListed(
//         uint256 indexed tokenId,
//         string codeLink,
//         uint256 price,
//         address creator
//     );
//     event AssetPurchased(uint256 indexed tokenId, address buyer, uint256 price);
//     event LicenseGranted(uint256 indexed tokenId, address licensee);

//     constructor(
//         address _registrationWorkflows,
//         address _licenseAttachmentWorkflows,
//         address _royaltyPolicy,
//         address _paymentToken,
//         address _nftContract
//     ) Ownable(msg.sender) {
//         registrationWorkflows = IRegistrationWorkflows(_registrationWorkflows);
//         licenseAttachmentWorkflows = ILicenseAttachmentWorkflows(
//             _licenseAttachmentWorkflows
//         );
//         royaltyPolicy = IRoyaltyPolicyLAP(_royaltyPolicy);
//         paymentToken = IERC20(_paymentToken);
//         nftContract = _nftContract;
//     }

//     function listAsset(
//         string memory codeLink,
//         uint256 price,
//         uint256 royaltyPercentage
//     ) external returns (uint256) {
//         require(
//             royaltyPercentage <= 100,
//             "Royalty percentage must be between 0 and 100"
//         );

//         (address ipId, uint256 tokenId) = registrationWorkflows
//             .mintAndRegisterIp(
//                 nftContract,
//                 msg.sender,
//                 IRegistrationWorkflows.IPMetadata({
//                     name: "LLM Asset",
//                     description: codeLink,
//                     mediaUrl: "",
//                     nftMetadataURI: codeLink
//                 })
//             );

//         uint256 licenseTermsId = licenseAttachmentWorkflows
//             .registerPILTermsAndAttach(
//                 payable(ipId),
//                 PILFlavors.commercialUse({
//                     mintingFee: price,
//                     currencyToken: address(paymentToken),
//                     royaltyPolicy: address(royaltyPolicy)
//                 })
//             );

//         llmAssets[tokenId] = LLMAsset({
//             codeLink: codeLink,
//             price: price,
//             creator: payable(msg.sender),
//             licenseTermsId: licenseTermsId,
//             isLicensed: false
//         });

//         emit AssetListed(tokenId, codeLink, price, msg.sender);
//         return tokenId;
//     }

//     function purchaseAsset(uint256 tokenId) external {
//         LLMAsset storage asset = llmAssets[tokenId];
//         require(asset.creator != address(0), "Asset does not exist");
//         require(
//             paymentToken.balanceOf(msg.sender) >= asset.price,
//             "Insufficient balance"
//         );

//         paymentToken.transferFrom(msg.sender, asset.creator, asset.price);

//         // Transfer NFT ownership
//         IIPAccount(payable(nftContract)).transferFrom(
//             asset.creator,
//             msg.sender,
//             tokenId
//         );

//         emit AssetPurchased(tokenId, msg.sender, asset.price);
//     }

//     function grantLicense(uint256 tokenId, address licensee) external {
//         require(
//             IIPAccount(nftContract).ownerOf(tokenId) == msg.sender,
//             "Only the owner can grant licenses"
//         );

//         address ipId = IIPAccount(nftContract).tokenToIP(tokenId);
//         LLMAsset storage asset = llmAssets[tokenId];

//         ILicensingModule(address(licenseAttachmentWorkflows)).grantLicense(
//             payable(ipId),
//             address(licenseAttachmentWorkflows),
//             asset.licenseTermsId,
//             licensee,
//             ""
//         );

//         asset.isLicensed = true;
//         emit LicenseGranted(tokenId, licensee);
//     }

//     function hasLicense(
//         uint256 tokenId,
//         address licensee
//     ) public view returns (bool) {
//         address ipId = IIPAccount(nftContract).tokenToIP(tokenId);
//         return
//             ILicensingModule(address(licenseAttachmentWorkflows)).hasLicense(
//                 payable(ipId),
//                 licensee
//             );
//     }

//     function getAssetDetails(
//         uint256 tokenId
//     ) external view returns (LLMAsset memory) {
//         return llmAssets[tokenId];
//     }
// }
