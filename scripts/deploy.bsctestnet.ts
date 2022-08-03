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
    // Factory
    const _feeToSetter = "0x36285fDa2bE8a96fEb1d763CA77531D696Ae3B0b";

    const GooseBumpsSwapFactory = await ethers.getContractFactory("GooseBumpsSwapFactory");
    const gooseBumpsSwapFactory = await GooseBumpsSwapFactory.deploy(_feeToSetter);
    await gooseBumpsSwapFactory.deployed();

    console.log("_feeToSetter: ", _feeToSetter)
    console.log("GooseBumpsSwapFactory deployed to:", gooseBumpsSwapFactory.address);
    // pairCodeHash
    const pairCodeHash = await gooseBumpsSwapFactory.pairCodeHash()
    console.log("pairCodeHash:", pairCodeHash);

    // Router
    const factory = gooseBumpsSwapFactory.address;
    const WETH = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd";

    const GooseBumpsSwapRouter02 = await ethers.getContractFactory("GooseBumpsSwapRouter02");
    const gooseBumpsSwapRouter02 = await GooseBumpsSwapRouter02.deploy(factory, WETH);
    await gooseBumpsSwapRouter02.deployed();

    console.log("factory: ", factory)
    console.log("WETH: ", WETH)
    console.log("GooseBumpsSwapRouter02 deployed to:", gooseBumpsSwapRouter02.address);


    // DEXManagement
    const _router = gooseBumpsSwapRouter02.address;
    const _treasury = "0x821965C1fD8B60D4B33E23C5832E2A7662faAADC";
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
