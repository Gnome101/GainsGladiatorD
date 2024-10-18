import { ethers, deployments, network } from "hardhat";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

import { Deployment } from "hardhat-deploy/dist/types";
import { Decimal } from "decimal.js";
import dotenv from "dotenv";

import { expect, assert } from "chai";
import { BigNumberish, Provider } from "ethers";

import axios, { AxiosRequestConfig, AxiosResponse, Method } from "axios";
import { execArgv } from "process";
import { chownSync } from "fs";

import exp from "constants";
import { Test } from "../typechain-types";
dotenv.config();

// Profiler configuration
const ENABLE_PROFILER = true;
const profiler = {
  start: (label: string) => {
    if (ENABLE_PROFILER) console.time(label);
  },
  end: (label: string) => {
    if (ENABLE_PROFILER) console.timeEnd(label);
  },
};

describe("Live Testnet Vault Tests", function () {
  let accounts: SignerWithAddress[];
  let deployer: SignerWithAddress;
  let user: SignerWithAddress;

  let Test: Test;

  beforeEach(async () => {
    const chainID = network.config.chainId;
    if (chainID == undefined) throw "Cannot find chainID";

    accounts = (await ethers.getSigners()) as unknown as SignerWithAddress[]; // could also do with getNamedAccounts

    await deployments.fixture(["Test"]);

    const testContract = (await deployments.get("Test")) as Deployment;

    Test = (await ethers.getContractAt(
      "Test",
      testContract.address.toString()
    )) as unknown as Test;
  });

  describe("Test", function () {
    it("User can deposit ", async function () {
      const numBefore = await Test.num();
      await Test.setNum(5);
      const numAfter = await Test.num();
      assert.equal(numBefore.toString(), "0");
      assert.equal(numAfter.toString(), "5");

      console.log("Testing");
    });
  });
});
