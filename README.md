# Advanced Sample Hardhat Project

This project demonstrates an advanced Hardhat use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

The project comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts. It also comes with a variety of other tools, preconfigured to work with the project code.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.ts
TS_NODE_FILES=true npx ts-node scripts/deploy.ts
npx eslint '**/*.{js,ts}'
npx eslint '**/*.{js,ts}' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.ts
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```

# Performance optimizations

For faster runs of your tests and scripts, consider skipping ts-node's type checking by setting the environment variable `TS_NODE_TRANSPILE_ONLY` to `1` in hardhat's environment. For more details see [the documentation](https://hardhat.org/guides/typescript.html#performance-optimizations).

## BSC Testnet

| Multi-Sig Wallet or Contract | Contract Address |
|-------------------|------------------|
| _feeToSetter | 0x36285fDa2bE8a96fEb1d763CA77531D696Ae3B0b |
| Treasury | 0x821965C1fD8B60D4B33E23C5832E2A7662faAADC |

| Contract Name | Contract Address |
|-------------------|------------------|
| WBNB | 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd |
| GooseBumpsSwapFactory | 0x75C821CCD003CC9E9Ea06008fAf9Ab8189B1EC56 |
| GooseBumpsSwapRouter02 | 0x31cB34991756FD1564b0DEBF2BFF3E522085EC02 |
| DEXManagement | 0xFD30B07eE421B307bdaCaf8ffE7329bF684227B2 |

| Token Name | Token Symbol | Contract Address | Pair Address |
|-------------------|-------------------|------------------|------------------|
| GooseBumps First Token | GBFT | 0xA6454bbA55F46Ef488c599c44867DF5eE3D6F543 | 0x3755298811C230597a075EFA05725930Aa38A0B8 |
| GooseBumps Second Token | GBST | 0xA490CfCE72c5d7344A177c6fCAdfBf0991816e93 |0xE76eE04D2A58Aeaff36763DD82E778d860501751 |
| GooseBumps Third Token | GBTT | 0x2FC145e7A2e6E1E83C55B7e73422072B70C73A77 | 0x4365E31B76196D23b143178A5f845D47c196766b |
| GooseBumps Firth Token | GBFT | 0x238CD26cccc1C714201Fc8bf49d453a39f494209 | 0xdeEeB6041bD4E3922E18f1F25771C71d7F64579e |

## Ropsten Testnet

| Multi-Sig Wallet or Contract | Contract Address |
|-------------------|------------------|
| _feeToSetter | 0x36285fDa2bE8a96fEb1d763CA77531D696Ae3B0b |
| Treasury | 0x821965C1fD8B60D4B33E23C5832E2A7662faAADC |

| Contract Name | Contract Address |
|-------------------|------------------|
| WETH | 0xc778417E063141139Fce010982780140Aa0cD5Ab |
| GooseBumpsSwapFactory | 0x354924E426FA21EbEc142BE760753D4407b8a59E |
| GooseBumpsSwapRouter02 | 0x48D874a757a05eAc5F353BA570266D39698F69F6 |
| DEXManagement | 0xa9B6a314abF836A1f05ce40Bd857fd89356083b5 |

| Token Name | Token Symbol | Contract Address | Pair Address |
|-------------------|-------------------|------------------|------------------|
| BSC Token0 | Token0 | 0x88fc3DcA85faBCa6Df62dDa115c3e529E19c369b |  |
| BSC Token1 | Token1 | 0x94595bFF70614B0308C390225bB2Cc622F6b6721 |  |
| BSC Token2 | Token2 | 0x13B1D5B3F93382c0AcF8026b12555b427DA2Eb7e |  |

## Ploygon Mainnet

| Multi-Sig Wallet or Contract | Contract Address |
|-------------------|------------------|
| _feeToSetter | 0x25bB177C3fE2f6a9B599616aCcD1Ed6f1765F2EB |
| Treasury | 0x821965C1fD8B60D4B33E23C5832E2A7662faAADC |

| Contract Name | Contract Address |
|-------------------|------------------|
| WMATIC | 0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270 |
| GooseBumpsSwapFactory | 0xa2A6A700452e4590c175C69C84c09655AbBC942F |
| GooseBumpsSwapRouter02 | 0x8E49F3b03D2F482af5c564d933f44De7FDD9C746 |
| DEXManagement | 0x34692A435F7B54706a50332AF61f5Be83D5b1a47 |

| Token Name | Token Symbol | Contract Address | Pair Address |
|-------------------|-------------------|------------------|------------------|
| Polygon Token0 | Token0 | 0x5FbF55B17e7799935ae499FB9aeadB677CA88566 |  |
| Polygon Token1 | Token1 | 0x4eda999a84Af9303D3298f0e34D1d509F6999DDF |  |
| Polygon Token1 | Token1 | 0x56D018869C5Ba97E34975484c904B32799111D87 |  |
| Polygon Token2 | Token2 | 0x0e5c05643215a50CA58e4774Ba3C27CEfe7310EF |  |

## BSC Mainnet

| Name | Contract Address |
|-------------------|------------------|
| _feeToSetter | 0x55FCfd515D9472D91689592F653F9fE59FC7663e |
| Treasury | 0xc227D09Cc73d4845871FA095A6C1Fa3c4b5b0fE1 |

| Contract Name | Contract Address |
|-------------------|------------------|
| WBNB | 0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c |
| GooseBumpsSwapFactory | 0x045e2e2A533dB4559533A71631962836c7802834 |
| GooseBumpsSwapRouter02 | 0x5F227dce0baaFECF49ac4987fB5c07A993d36291 |
| DEXManagement | 0x4D9cE73103C4FA07c4a6Fee7749CE37ec2804722 |

| Token Name | Token Symbol | Contract Address | Pair Address |
|-------------------|-------------------|------------------|------------------|
| BSC Token0 | Token0 | 0x649ec09F064038244715A9d08B66b7D84db4449A |  |
| BSC Token1 | Token1 | 0x1dA2340b2b4Fb163918121A1A4A3d6cC6a9Ab3Ca |  |
| BSC Token2 | Token2 | 0xeA4427a1E526e5dC996058307413f6b14E1b7Cb7 |  |
