const hre = require("hardhat");
const { deployments, ethers } = hre;
const {
  createLitAction,
  mintGrantBurnPKP,
  executeSwapAction,
} = require("../utils/util");
async function main() {
  const accounts = await ethers.getSigners();
  //   for (const account of accounts) {
  //     console.log(account.address);
  //   }

  // const ipfsCid = await createLitAction();
  const ipfsCid = "QmWxvJQG31JXxz8AHBGJPfSccrAjbyyxcZ3W1DBnfWsB7B";
  // const pkpInfo = await mintGrantBurnPKP(ipfsCid);
  // console.log(pkpInfo);
  const pkpInfo = {
    tokenId:
      "18860470054839200319159849969344254889725209876444016177312279746269791411391",
    publicKey:
      "0x04f6493a3eb9eb385d479e8d2aaad80371a37540c651da1f13aaf22ab49d6b90ac254db59e49b7fd1a276b3ad45c0be9c6009e319e014b28b103497574adc6c2c3",
    ethAddress: "0x83f76e33B8cfaFa7DaA27659ea3e78c1B9b8517E",
  };

  await hre.switchNetwork("uni");

  const TestTokenUni = await hre.ethers.getContractAt(
    "TestToken",
    "0x2B0318d3e4C888Db35103C3E563d985E84CD2d2d"
  );
  const tx1 = await TestTokenUni.transfer(
    pkpInfo.ethAddress,
    "1000000000000000000"
  );
  await tx1.wait();
  await console.log(hre.network.config.chainId);

  //0x9Da6efC54e0cA77b4a127Ea555C77df3B3dc294e
  await hre.switchNetwork("flow");
  const TestTokenFlow = await hre.ethers.getContractAt(
    "TestToken",
    "0xF00B21BaF761678740147CDaC8eC096E39D9c4CF"
  );
  const tx2 = await TestTokenFlow.transfer(
    pkpInfo.ethAddress,
    "1000000000000000000"
  );
  await tx2.wait();
  console.log(hre.network.config.chainId);

  await executeSwapAction(ipfsCid, pkpInfo);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
