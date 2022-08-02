// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // BSC Testnet
  // const factory = "0x75C821CCD003CC9E9Ea06008fAf9Ab8189B1EC56"; // BSC Testnet Factory Address
  // const WETH = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd"; // BSC Testnet WBNB Address
  
  // Ropsten Testnet
  // const factory = "0x354924E426FA21EbEc142BE760753D4407b8a59E"; // Ropsten Testnet Factory Address
  // const WETH = "0xc778417E063141139Fce010982780140Aa0cD5Ab"; // Ropsten Testnet WETH Address
  
  // Polygon Mainnet
  // const factory = "0xa2A6A700452e4590c175C69C84c09655AbBC942F"; // Polygon Mainnet Factory Address
  // const WETH = "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270"; // Polygon Mainnet WMTIC Address
  
  // BSC Mainnet
  const factory = "0x045e2e2A533dB4559533A71631962836c7802834"; // BSC Mainnet Factory Address
  const WETH = "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c"; // BSC Mainnet WBNB Address
  
  // We get the contract to deploy
  const GooseBumpsSwapRouter02 = await ethers.getContractFactory("GooseBumpsSwapRouter02");
  const gooseBumpsSwapRouter02 = await GooseBumpsSwapRouter02.deploy(factory, WETH);

  await gooseBumpsSwapRouter02.deployed();
  
  console.log("GooseBumpsSwapRouter02 deployed to:", gooseBumpsSwapRouter02.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
