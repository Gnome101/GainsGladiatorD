import "@nomiclabs/hardhat-etherscan";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import "solidity-coverage";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";
import "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-chai-matchers";
import "@typechain/hardhat";
import "@nomicfoundation/hardhat-foundry";
import * as envEnc from "@chainlink/env-enc";
envEnc.config();

import dotenv from "dotenv";

dotenv.config();

const MAINNET_RPC_URL =
  process.env.MAINNET_RPC_URL ||
  process.env.ALCHEMY_MAINNET_RPC_URL ||
  "https://eth-mainnet.alchemyapi.io/v2/your-api-key";

const REPORT_GAS = process.env.REPORT_GAS || false;

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: process.env.ARB_SEP_RPC,
      },
      chainId: 31337,
      allowBlocksWithSameTimestamp: true,
      gasPrice: "auto",
      initialBaseFeePerGas: 0,
      allowUnlimitedContractSize: true,

      // mining: {
      //   auto: false,
      // },
    },
    arbSep: {
      url: process.env.ARB_SEP_RPC || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 421614,
      timeout: 200000, // Increase the timeout value
      saveDeployments: true,
    },
    story: {
      url: process.env.STORY_RPC || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 1513,
      timeout: 200000, // Increase the timeout value
      saveDeployments: true,
    },
    rootStalk: {
      url: process.env.ROOT_STALK || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 31,
      timeout: 200000, // Increase the timeout value
      saveDeployments: true,
    },
    // airDAO: {
    //   url: process.env.STORY_RPC || "",
    //   accounts:
    //     process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    //   chainId: 1513,
    //   timeout: 200000, // Increase the timeout value
    //   saveDeployments: true,
    // },
    // flowEVM: {
    //   url: process.env.STORY_RPC || "",
    //   accounts:
    //     process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    //   chainId: 1513,
    //   timeout: 200000, // Increase the timeout value
    //   saveDeployments: true,
    // },
    // skale: {
    //   url: process.env.STORY_RPC || "",
    //   accounts:
    //     process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    //   chainId: 1513,
    //   timeout: 200000, // Increase the timeout value
    //   saveDeployments: true,
    // },
  },

  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
    bob: {
      default: 1,
    },
    cat: {
      default: 2,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.26",
        settings: {
          evmVersion: "cancun",
          optimizer: {
            enabled: true,
            runs: 1,
            details: {
              yul: true, //https://github.com/ethereum/solidity/issues/11638#issuecomment-1101524130 (added this so that coverage works)
            },
          },
          //viaIR: true,
        },
      },
    ],
  },
  etherscan: {
    apiKey: {
      // arbitrum: networks.arbitrum.verifyApiKey,
      arbSep: process.env.ARBISCAN_API_KEY,
    },
    customChains: [
      {
        network: "arbSep",
        chainId: 421614,
        urls: {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://sepolia.arbiscan.io/",
        },
      },
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia-explorer.base.org",
        },
      },
      {
        network: "optimismSepolia",
        chainId: 11155420,
        urls: {
          apiURL: "https://api-sepolia-optimistic.etherscan.io/api", // https://docs.optimism.etherscan.io/v/optimism-sepolia-etherscan
          browserURL: "https://sepolia-optimistic.etherscan.io/",
        },
      },
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com",
        },
      },
      {
        network: "storyNetwork",
        chainId: 1513,
        urls: {
          apiURL: "https://story-testnet.socialscan.io/api", // https://docs.story.foundation/docs/story-network
          browserURL: "https://story-testnet.socialscan.io",
        },
      },
    ],
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    showTimeSpent: true,
    token: "ETH",
  },
  mocha: {
    timeout: 1500000, // 500 seconds max for running tests
    parallel: false,
  },
};
