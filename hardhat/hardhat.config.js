require("dotenv").config();

require("@nomiclabs/hardhat-waffle");
require('hardhat-abi-exporter');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    localhost: {
      url: "http://localhost:8545",
      chainId: 31337,
      /*      
        notice no mnemonic here? it will just use account 0 of the hardhat node to deploy
        (you can put in a mnemonic here to set the deployer locally)  
      */
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.RINKEBY_INFURA_KEY}`,
      accounts: [`${process.env.RINKEBY_DEPLOYER_PRIV_KEY}`],
      chainId: 4,
    },
    kovan: {
      // https://kovan.infura.io/v3/575524971ad7458a9181668874d68b83
      url: `https://rinkeby.infura.io/v3/${process.env.KOVAN_INFURA_KEY}`,
      accounts: [`${process.env.KOVAN_DEPLOYER_PRIV_KEY}`],
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.MAINNET_INFURA_KEY}`,
      accounts: [`${process.env.MAINNET_DEPLOYER_PRIV_KEY}`],
    },
    ropsten: {
      // https://ropsten.infura.io/v3/575524971ad7458a9181668874d68b83
      url: `https://ropsten.infura.io/v3/${process.env.ROPSTEN_INFURA_KEY}`,
      accounts: [`${process.env.ROPSTEN_DEPLOYER_PRIV_KEY}`],
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.GOERLI_INFURA_KEY}`,
      accounts: [`${process.env.GOERLI_DEPLOYER_PRIV_KEY}`],
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.11",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  }
};

