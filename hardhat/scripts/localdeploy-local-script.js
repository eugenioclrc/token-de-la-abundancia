// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

require('dotenv').config();

const DEV_ADDRESS = process.env.DEV_ADDRESS;
const { ethers } = hre;

const fs = require("fs");
const path = require("path");

async function main() {
  await hre.run("compile");
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const [deployer] = await ethers.getSigners();
  // We get the contract to deploy
  const Mandala = await ethers.getContractFactory("MandalaTokenNftAbundancia");
  const mandala = await Mandala.deploy(DEV_ADDRESS);
  await mandala.deployed();

  const MulticallMakerdao = await ethers.getContractFactory("MulticallMakerdao");
  const multicallMakerdao = await MulticallMakerdao.deploy();
  await multicallMakerdao.deployed();
  console.log("multicallMakerdao deployed to:", multicallMakerdao.address);

  

  console.log("mandando ether a cuenta de test");
  await deployer.sendTransaction({
    to: DEV_ADDRESS,
    value: ethers.utils.parseEther("1.0"),
  });
  console.log("mandala deployed to:", mandala.address);
  copyAbi();

  const tonyNFT = await mandala.tonyNFT();
  
  fs.writeFileSync(path.join(__dirname, "../../web/src/store/data.json"), JSON.stringify({
    mandalaAddress: mandala.address,
    multicallAddress: multicallMakerdao.address,
    tonyAddress: tonyNFT,
    NETWORK_ID: hre.network.config.chainId || '31337',
  }, null, 2));
}

function copyAbi() {
  const copyRecursiveSync = (src, dest) => {
    const exists = fs.existsSync(src);
    const stats = exists && fs.statSync(src);
    const isDirectory = exists && stats.isDirectory();
    if (isDirectory) {
      try {
        fs.mkdirSync(dest);
      } catch (err) {
      }
      fs.readdirSync(src).forEach(function(childItemName) {
        copyRecursiveSync(path.join(src, childItemName),
                          path.join(dest, childItemName));
      });
    } else {
      fs.copyFileSync(src, dest);
    }
  };

  copyRecursiveSync(path.join(__dirname, "../abi/contracts"), path.join(__dirname, "../../web/src/store/abi"));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
