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

  // BSC And Other Testnet
  // const _feeToSetter = "0x36285fDa2bE8a96fEb1d763CA77531D696Ae3B0b";

  // Polygon Mainnet
  // const _feeToSetter = "0x25bB177C3fE2f6a9B599616aCcD1Ed6f1765F2EB";

  // BSC Mainnet
  const _feeToSetter = "0x55FCfd515D9472D91689592F653F9fE59FC7663e";

  const GooseBumpsSwapFactory = await ethers.getContractFactory("GooseBumpsSwapFactory");
  const gooseBumpsSwapFactory = await GooseBumpsSwapFactory.deploy(_feeToSetter);

  await gooseBumpsSwapFactory.deployed();

  console.log("GooseBumpsSwapFactory deployed to:", gooseBumpsSwapFactory.address);

  const pairCodeHash = await gooseBumpsSwapFactory.pairCodeHash()
  console.log("pairCodeHash:", pairCodeHash);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
