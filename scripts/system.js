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
  const ipfsCid = "QmRSc42YayiCvc2D8CzJ7e4XaCbjUj84KsBpBsUPqTZX7B";
  // const pkpInfo = await mintGrantBurnPKP(ipfsCid);
  const pkpInfo = {
    tokenId:
      "106656399718227858198816899830774292885269051568784903158859424321700025451209",
    publicKey:
      "0x04f1f5f4295512604e8b5a7373a75ab320b3def634355ab764af48ffe47deea891fce5e536c63a8f286767bc4010b93c7753af97c748233197b11382ddb3f44f02",
    ethAddress: "0x9Da6efC54e0cA77b4a127Ea555C77df3B3dc294e",
  };
  await hre.switchNetwork("uni");
  const TestTokenUni = await hre.ethers.getContractAt(
    "TestToken",
    "0x2B0318d3e4C888Db35103C3E563d985E84CD2d2d"
  );
  // const tx1 = await TestTokenUni.transfer(
  //   pkpInfo.ethAddress,
  //   "1000000000000000000"
  // );
  // await tx1.wait();
  console.log(hre.network.config.chainId);
  //0x9Da6efC54e0cA77b4a127Ea555C77df3B3dc294e
  await hre.switchNetwork("flow");
  const TestTokenFlow = await hre.ethers.getContractAt(
    "TestToken",
    "0xF00B21BaF761678740147CDaC8eC096E39D9c4CF"
  );
  // const tx2 = await TestTokenFlow.transfer(
  //   pkpInfo.ethAddress,
  //   "1000000000000000000"
  // );
  // await tx2.wait();
  console.log(hre.network.config.chainId);

  await executeSwapAction(ipfsCid, pkpInfo);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
