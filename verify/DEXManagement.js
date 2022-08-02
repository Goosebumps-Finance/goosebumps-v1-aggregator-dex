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

module.exports = [
    _router,
    _treasury,
    _swapFee,
    _swapFee0x,
];