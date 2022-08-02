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

  // We get the contract to deploy
  
  // BSC Testnet
  // const _router = "0x31cB34991756FD1564b0DEBF2BFF3E522085EC02"; // Bsc testnet goosebumps dex

  // Ropsten Testnet
  // const _router = "0x48D874a757a05eAc5F353BA570266D39698F69F6"; // Ropsten testnet goosebumps dex

  // Polygon Mainnet
  // const _router = "0x8E49F3b03D2F482af5c564d933f44De7FDD9C746"; // Polygon mainnet goosebumps dex

  // BSC Mainnet
  const _router = "0x5F227dce0baaFECF49ac4987fB5c07A993d36291"; // Bsc mainnet goosebumps dex
  
  // BSC Testnet, Ropsten Testnet, Polygon Mainnet
  // const _treasury = "0x821965C1fD8B60D4B33E23C5832E2A7662faAADC";

  // BSC Mainnet
  const _treasury = "0xc227D09Cc73d4845871FA095A6C1Fa3c4b5b0fE1";

  const _swapFee = 10; // 0.1%
  const _swapFee0x = 5; // 0.05%
  const DEXManagement = await ethers.getContractFactory("DEXManagement");
  const dexManagement = await DEXManagement.deploy(_router, _treasury, _swapFee, _swapFee0x);

  await dexManagement.deployed();

  console.log("DEXManagement deployed to:", dexManagement.address);

  try {
    console.log("TREASURY address of DEXManagement:", await dexManagement.TREASURY());
  } catch (error) {
    console.log(error)
  }
  try {
    console.log("SWAP_FEE address of DEXManagement:", await dexManagement.SWAP_FEE());
  } catch (error) {
    console.log(error)
  }
  try {
    console.log("SWAP_FEE address of DEXManagement:", await dexManagement.SWAP_FEE_0X());
  } catch (error) {
    console.log(error)
  }
  try {
    console.log("router address of DEXManagement:", await dexManagement.dexRouter_());
  } catch (error) {
    console.log(error)
  }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
