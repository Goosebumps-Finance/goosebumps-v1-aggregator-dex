// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.6.12;

import './interfaces/IGooseBumpsSwapFactory.sol';
import './GooseBumpsSwapPair.sol';

contract GooseBumpsSwapFactory is IGooseBumpsSwapFactory {

    address public override feeTo;
    /**
     * @dev Must be Multi-Signature Wallet.
     */
    address public override multiSigFeeToSetter;

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _multiSigFeeToSetter) public {
        require(_multiSigFeeToSetter != address(0), "GooseBumpsSwap: ZERO_ADDRESS");
        multiSigFeeToSetter = _multiSigFeeToSetter;
    }

    function allPairsLength() external override view returns (uint) {
        return allPairs.length;
    }

    function pairCodeHash() external pure returns (bytes32) {
        return keccak256(type(GooseBumpsSwapPair).creationCode);
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'GooseBumpsSwap: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'GooseBumpsSwap: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(GooseBumpsSwapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        GooseBumpsSwapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == multiSigFeeToSetter, 'GooseBumpsSwap: FORBIDDEN');
        require(_feeTo != address(0), "GooseBumpsSwap: ZERO_ADDRESS");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _multiSigFeeToSetter) external override {
        require(msg.sender == multiSigFeeToSetter, 'GooseBumpsSwap: FORBIDDEN');
        require(_multiSigFeeToSetter != address(0), "GooseBumpsSwap: ZERO_ADDRESS");
        multiSigFeeToSetter = _multiSigFeeToSetter;
    }
}