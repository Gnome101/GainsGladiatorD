const { network, deployments: hardhatDeployments, ethers } = require("hardhat");
const { verify } = require("../utils/verify");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  log("------------------------------------------------------------");
  let args = ["TestToken", "TST"];
  const chainId = network.config.chainId;
  console.log("Your Chain ID:", chainId);
  const TestToken = await deploy("TestToken", {
    from: deployer,
    args: args,
    log: true,
  });

  if (chainId != 31337) {
    log("Verifying...");
    await verify(TestToken.address, args, "contracts/TestToken:TestToken.sol");
  }
};

module.exports.tags = ["", "Test"];
