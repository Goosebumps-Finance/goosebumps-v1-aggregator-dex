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

    // BSC Mainnet
    // Factory
    const _multiSigFeeToSetter = "0xd078bd7bb85EC4F57340cE8C84ae647474AC12bf";

    const GooseBumpsSwapFactory = await ethers.getContractFactory("GooseBumpsSwapFactory");
    const gooseBumpsSwapFactory = await GooseBumpsSwapFactory.deploy(_multiSigFeeToSetter);
    await gooseBumpsSwapFactory.deployed();

    console.log("_multiSigFeeToSetter: ", _multiSigFeeToSetter)
    console.log("GooseBumpsSwapFactory deployed to:", gooseBumpsSwapFactory.address);
    // pairCodeHash
    const pairCodeHash = await gooseBumpsSwapFactory.pairCodeHash()
    console.log("pairCodeHash:", pairCodeHash);

    // Router
    const factory = gooseBumpsSwapFactory.address;
    const WETH = "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c";

    const GooseBumpsSwapRouter02 = await ethers.getContractFactory("GooseBumpsSwapRouter02");
    const gooseBumpsSwapRouter02 = await GooseBumpsSwapRouter02.deploy(factory, WETH);
    await gooseBumpsSwapRouter02.deployed();

    console.log("factory: ", factory)
    console.log("WETH: ", WETH)
    console.log("GooseBumpsSwapRouter02 deployed to:", gooseBumpsSwapRouter02.address);

    // DEXManagement
    const _router = gooseBumpsSwapRouter02.address;
    const _treasury = "0xc227D09Cc73d4845871FA095A6C1Fa3c4b5b0fE1";
    const _swapFee = 10; // 0.1%
    const _swapFee0x = 5; // 0.05%

    const DEXManagement = await ethers.getContractFactory("DEXManagement");
    const dexManagement = await DEXManagement.deploy(_router, _treasury, _swapFee, _swapFee0x);
    await dexManagement.deployed();

    console.log("_router: ", _router);
    console.log("_treasury: ", _treasury);
    console.log("_swapFee: ", _swapFee);
    console.log("_swapFee0x: ", _swapFee0x);
    console.log("DEXManagement deployed to:", dexManagement.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
