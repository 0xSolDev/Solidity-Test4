require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-web3');
require('@openzeppelin/hardhat-upgrades');
require('hardhat-deploy');
require('hardhat-deploy-ethers');
require('solidity-coverage');
require('dotenv').config();

module.exports = {
  networks: {
    hardhat: {
      gas: 10000000,
      accounts: {
        accountsBalance: '100000000000000000000000000',
      },
      allowUnlimitedContractSize: true,
      timeout: 1000000,
    },
    mainnet: {
      url: 'https://rpc-mainnet.kcc.network',
      chainId: 321,
      accounts: [process.env.MAINNET_PRIVATE_KEY],
    },
  },
  solidity: {
    version: '0.7.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};
