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
  args = [TestToken.address];
  const Escrow = await deploy("Escrow", {
    from: deployer,
    args: args,
    log: true,
  });

  if (chainId != 31337) {
    log("Verifying...");
    await verify(Escrow.address, args, "contracts/Escrow:Escrow.sol");
  }
};

module.exports.tags = ["Escrow", "Test"];
