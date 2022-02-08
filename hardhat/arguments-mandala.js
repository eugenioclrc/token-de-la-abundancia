require("dotenv").config();
// npx hardhat verify  --constructor-args arguments-mandala.js --show-stack-traces --network rinkeby 0x5cea8a30e54315dae7d296a646fa149aa292ee97

const ethers = require('ethers');

module.exports =[
  process.env.DEV_ADDRESS,
  'http://127.0.0.1:3000/app/token?token=',
  ethers.utils.parseEther("0.025"),
  "4"
];

  