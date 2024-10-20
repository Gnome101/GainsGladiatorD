const { network, deployments: hardhatDeployments, ethers } = require("hardhat");
const { verify } = require("../utils/verify");

const ipAssetRegistryAddr = "0x1a9d0d28a0422f26d31be72edc6f13ea4371e11b";
// Protocol Periphery - RegistrationWorkflows
const registrationWorkflowsAddr = "0x601c24bfa5ae435162a5dc3cd166280c471d16c8";

// Protocol Core - LicensingModule
const licensingModuleAddr = "0xd81fd78f557b457b4350cb95d20b547bfeb4d857";
// Protocol Core - LicenseToken
const licenseTokenAddr = "0xc7a302e03cd7a304394b401192bfed872af501be";
// Protocol Core - PILicenseTemplate
const pilTemplateAddr = "0x0752f61e59fd2d39193a74610f1bd9a6ade2e3f9";
const royaltyModuleAddr = "0x3c27b2d7d30131d4b58c3584fd7c86e3358744de";
const susdAddr = "0x91f6F05B08c16769d3c85867548615d270C42fC7";

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  log("------------------------------------------------------------");
  let args = [
    ipAssetRegistryAddr,
    registrationWorkflowsAddr,
    licensingModuleAddr,
    pilTemplateAddr,
    royaltyModuleAddr,
    susdAddr,
  ];
  const chainId = network.config.chainId;
  console.log("Your Chain ID:", chainId);

  const TestToken = await deploy("IPACombine", {
    from: deployer,
    args: args,
    log: true,
  });

  if (chainId != 31337) {
    log("Verifying...");
    await verify(
      TestToken.address,
      args,
      "contracts/IPACombine:IPACombine.sol"
    );
  }
};

module.exports.tags = ["", "Test"];
