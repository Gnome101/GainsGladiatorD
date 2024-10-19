require("@nomiclabs/hardhat-etherscan");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require("solidity-coverage");
require("hardhat-gas-reporter");
require("hardhat-contract-sizer");
require("@nomicfoundation/hardhat-network-helpers");
require("@nomicfoundation/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");
require("@typechain/hardhat");
require("@nomicfoundation/hardhat-foundry");
require("hardhat-switch-network");
require("dotenv").config();

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
    },
    arbSep: {
      url: process.env.ARB_SEP_RPC || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 421614,
      timeout: 200000,
      saveDeployments: true,
    },
    flow: {
      url: process.env.FLOW_RPC || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 545,
      timeout: 200000,
      saveDeployments: true,
    },
    story: {
      url: process.env.STORY_RPC || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 1513,
      timeout: 200000,
      saveDeployments: true,
    },
    rootStalk: {
      url: process.env.ROOT_STALK || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 31,
      timeout: 200000,
      saveDeployments: true,
    },
    uni: {
      url: process.env.UNI_CHAIN_RPC || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 1301,
      timeout: 200000,
      saveDeployments: true,
    },
  },

  namedAccounts: {
    deployer: {
      default: 0,
      1: 0,
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
              yul: true,
            },
          },
        },
      },
    ],
  },
  etherscan: {
    apiKey: {
      arbSep: process.env.ARBISCAN_API_KEY,
      flow: "abc",
      unichain: "abc",
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
          apiURL: "https://api-sepolia-optimistic.etherscan.io/api",
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
          apiURL: "https://story-testnet.socialscan.io/api",
          browserURL: "https://story-testnet.socialscan.io",
        },
      },
      {
        network: "flow",
        chainId: 545,
        urls: {
          apiURL: "https://evm-testnet.flowscan.io//api",
          browserURL: "https://evm-testnet.flowscan.io/",
        },
      },
      {
        network: "unichain",
        chainId: 1301,
        urls: {
          apiURL: "https://api-sepolia.uniscan.xyz/api",
          browserURL: "https://sepolia.uniscan.xyz/",
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
    timeout: 1500000,
    parallel: false,
  },
};
