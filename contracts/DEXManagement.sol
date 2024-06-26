// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./utils/Ownable.sol";
import "./utils/Pausable.sol";
import "./utils/ReentrancyGuard.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IGooseBumpsSwapRouter02.sol";
import "./interfaces/IGooseBumpsSwapFactory.sol";

contract DEXManagement is Ownable, Pausable, ReentrancyGuard {

    //--------------------------------------
    // Constant
    //--------------------------------------.
    uint256 public MAX_SWAP_FEE = 3000;      // Max Fee = 3000 / 10000 * 100 = 30%

    //--------------------------------------
    // State variables
    //--------------------------------------

    address public TREASURY;                // Must be multi-sig wallet or Treasury contract
    uint256 public SWAP_FEE;                // Fee = SWAP_FEE / 10000
    uint256 public SWAP_FEE_0X;             // Fee = SWAP_FEE_0X / 10000

    IGooseBumpsSwapRouter02 public dexRouter_;

    mapping(address => bool) public isSwapTargetList;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event LogReceived(address indexed sender, uint value);
    event LogFallback(address indexed sender, uint value);
    event LogUpdateSwapTargetList(address indexed sender, address indexed swapTarget, bool indexed bValue);
    event LogSetTreasury(address indexed sender, address indexed treasury);
    event LogSetSwapFee(address indexed sender, uint256 fee);
    event LogSetSwapFee0x(address indexed sender, uint256 fee0x);
    event LogSetDexRouter(address indexed sender, address indexed router);
    event LogWithdraw(address indexed sender, address indexed token, uint256 tokenAmount, uint256 ethAmount);
    event LogSwapExactTokensForTokens(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
    event LogSwapExactETHForTokens(address indexed token, uint256 amountIn, uint256 amountOut);
    event LogSwapExactTokenForETH(address indexed token, uint256 amountIn, uint256 amountOut);
    event LogSwapExactTokensForTokensOn0x(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
    event LogSwapExactETHForTokensOn0x(address indexed token, uint256 amountIn, uint256 amountOut);
    event LogSwapExactTokenForETHOn0x(address indexed token, uint256 amountIn, uint256 amountOut);

    //-------------------------------------------------------------------------
    // CONSTRUCTOR
    //-------------------------------------------------------------------------

    /**
     * @param   _router: router address
     * @param   _treasury: treasury address
     * @param   _swapFee: swap fee value
     * @param   _swapFee0x: swap fee for 0x value
     */
    constructor(address _router, address _treasury, uint256 _swapFee, uint256 _swapFee0x ) 
    {
        require(_treasury != address(0), "Zero address");
        require(_swapFee <= MAX_SWAP_FEE && _swapFee0x <= MAX_SWAP_FEE, "SWAP_FEE_MIN_0_MAX_30");
        dexRouter_ = IGooseBumpsSwapRouter02(_router);
        TREASURY = _treasury;
        SWAP_FEE = _swapFee;
        SWAP_FEE_0X = _swapFee0x;
    }

    /**
     * @param   path: path
     * @param   _amountIn: amount of input token
     * @return  uint256: Given an input asset amount, returns the maximum output amount of the other asset.
     */
    function getAmountOut(address[] memory path, uint256 _amountIn) external view returns(uint256) { 
        uint256[] memory amountOutMaxs = dexRouter_.getAmountsOut(_amountIn * (10000 - SWAP_FEE) / 10000, path);
        return amountOutMaxs[path.length - 1];  
    }

    /**
     * @param   path: path
     * @param   _amountOut: amount of output token
     * @return  uint256: Returns the minimum input asset amount required to buy the given output asset amount.
     */
    function getAmountIn(address[] memory path, uint256 _amountOut) external view returns(uint256) { 
        uint256[] memory amountInMins = dexRouter_.getAmountsIn(_amountOut, path);
        return amountInMins[0] * 10000 / (10000 - SWAP_FEE);
    }

    /**
     * @param   path: Swap path on GooseBumps
     * @param   _amountIn: Amount of InputToken to swap on GooseBumps
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ERC20 token on GooseBumps
     */
    function swapExactTokensForTokens(
        address[] calldata path,
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external whenNotPaused nonReentrant {
        require(_amountIn > 0 , "Invalid amount");

        require(IERC20(path[0]).transferFrom(_msgSender(), address(this), _amountIn), "Faild TransferFrom");

        uint256 _swapAmountIn = _amountIn * (10000 - SWAP_FEE) / 10000;
        
        require(IERC20(path[0]).approve(address(dexRouter_), _swapAmountIn), "Failed Approve");

        uint256 boughtAmount = IERC20(path[path.length - 1]).balanceOf(to);
        dexRouter_.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _swapAmountIn,
            _amountOutMin,  
            path,
            to,
            deadline
        );
        boughtAmount = IERC20(path[path.length - 1]).balanceOf(to) - boughtAmount;

        require(IERC20(path[0]).transfer(TREASURY, _amountIn - _swapAmountIn), "Faild Transfer");

        emit LogSwapExactTokensForTokens(path[0], path[path.length - 1], _amountIn, boughtAmount);
    }

    /**
     * @param   tokenA: InputToken Address to swap on 0x, The `sellTokenAddress` field from the API response
     * @param   tokenB: OutputToken Address to swap on 0x, The `buyTokenAddress` field from the API response
     * @param   _amountIn: Amount of InputToken to swap on 0x, The `sellAmount` field from the API response
     * @param   spender: Spender to approve the amount of InputToken, The `allowanceTarget` field from the API response
     * @param   swapTarget: SwapTarget contract address, The `to` field from the API response
     * @param   swapCallData: CallData, The `data` field from the API response
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ERC20 token by using 0x protocol
     */
    function swapExactTokensForTokensOn0x(
        address tokenA,
        address tokenB,
        uint256 _amountIn,
        address spender,
        address payable swapTarget,
        bytes calldata swapCallData,
        address to,
        uint deadline
    ) external whenNotPaused nonReentrant {
        require(deadline >= block.timestamp, "DEXManagement: EXPIRED");
        require(_amountIn > 0 , "Invalid amount");

        require(IERC20(tokenA).transferFrom(_msgSender(), address(this), _amountIn), "Faild TransferFrom");
        uint256 _swapAmountIn = _amountIn * (10000 - SWAP_FEE_0X) / 10000;
        
        require(IERC20(tokenA).approve(spender, _swapAmountIn), "Failed Approve");
        
        uint256 boughtAmount = IERC20(tokenB).balanceOf(address(this));

        require(isSwapTargetList[address(swapTarget)], "Faild SwapTarget");
        (bool success,) = swapTarget.call(swapCallData);
        require(success, "SWAP_CALL_FAILED");

        boughtAmount = IERC20(tokenB).balanceOf(address(this)) - boughtAmount;

        require(IERC20(tokenB).transfer(to, boughtAmount), "Faild Transfer");

        require(IERC20(tokenA).transfer(TREASURY, _amountIn - _swapAmountIn), "Faild Transfer");

        emit LogSwapExactTokensForTokensOn0x(tokenA, tokenB, _amountIn, boughtAmount);
    }

    /**
     * @param   path: Swap path on GooseBumps
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ETH to ERC20 token on GooseBumps
     */
    function swapExactETHForTokens(
        address[] calldata path,
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external payable whenNotPaused nonReentrant {
        require(msg.value > 0 , "Invalid amount");

        uint256 _swapAmountIn = msg.value * (10000 - SWAP_FEE) / 10000;

        uint256 boughtAmount = IERC20(path[path.length - 1]).balanceOf(to);
        dexRouter_.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _swapAmountIn}(                
            _amountOutMin,
            path,
            to,
            deadline
        );
        boughtAmount = IERC20(path[path.length - 1]).balanceOf(to) - boughtAmount;

        payable(TREASURY).transfer(msg.value - _swapAmountIn);

        emit LogSwapExactETHForTokens(path[path.length - 1], msg.value, boughtAmount);
    }

    /**
     * @param   token: OutputToken Address to swap on 0x, The `buyTokenAddress` field from the API response
     * @param   swapTarget: SwapTarget contract address, The `to` field from the API response
     * @param   swapCallData: CallData, The `data` field from the API response
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ETH to ERC20 token by using 0x protocol
     */
    function swapExactETHForTokensOn0x(
        address token, 
        address payable swapTarget, 
        bytes calldata swapCallData, 
        address to,
        uint deadline
    ) external payable whenNotPaused nonReentrant {
        require(deadline >= block.timestamp, "DEXManagement: EXPIRED");
        require(msg.value > 0 , "Invalid amount");

        uint256 _swapAmountIn = msg.value * (10000 - SWAP_FEE_0X) / 10000;
        
        uint256 boughtAmount = IERC20(token).balanceOf(address(this));

        require(isSwapTargetList[address(swapTarget)], "Faild SwapTarget");
        (bool success,) = swapTarget.call{value: _swapAmountIn}(swapCallData);
        require(success, "SWAP_CALL_FAILED");

        boughtAmount = IERC20(token).balanceOf(address(this)) - boughtAmount;

        require(IERC20(token).transfer(to, boughtAmount), "Faild Transfer");

        payable(TREASURY).transfer(msg.value - _swapAmountIn);

        emit LogSwapExactETHForTokensOn0x(token, msg.value, boughtAmount);
    }

    /**
     * @param   path: Swap path on GooseBumps
     * @param   _amountIn: Amount of InputToken to swap on GooseBumps
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ETH on GooseBumps
     */
    function swapExactTokenForETH(
        address[] calldata path,
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external whenNotPaused nonReentrant {
        require(_amountIn > 0 , "Invalid amount");
        
        require(IERC20(path[0]).transferFrom(_msgSender(), address(this), _amountIn), "Faild TransferFrom");
        uint256 _swapAmountIn = _amountIn * (10000 -  SWAP_FEE) / 10000;
        
        require(IERC20(path[0]).approve(address(dexRouter_), _swapAmountIn), "Failed Approve");

        uint256 boughtAmount = address(to).balance;
        dexRouter_.swapExactTokensForETHSupportingFeeOnTransferTokens(   
            _swapAmountIn,         
            _amountOutMin,         
            path,
            to,
            deadline
        );
        boughtAmount = address(to).balance - boughtAmount;

        require(IERC20(path[0]).transfer(TREASURY, _amountIn - _swapAmountIn), "Faild Transfer");

        emit LogSwapExactTokenForETH(path[0], _amountIn, boughtAmount);
    }

    /**
     * @param   token: InputToken Address to swap on 0x, The `sellTokenAddress` field from the API response
     * @param   _amountIn: Amount of InputToken to swap on 0x, The `sellAmount` field from the API response
     * @param   spender: Spender to approve the amount of InputToken, The `allowanceTarget` field from the API response
     * @param   swapTarget: SwapTarget contract address, The `to` field from the API response
     * @param   swapCallData: CallData, The `data` field from the API response
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ETH by using 0x protocol
     */
    function swapExactTokenForETHOn0x(
        address token,
        uint256 _amountIn,
        address spender,
        address payable swapTarget,
        bytes calldata swapCallData,
        address to,
        uint deadline
    ) external whenNotPaused nonReentrant {
        require(deadline >= block.timestamp, "DEXManagement: EXPIRED");
        require(_amountIn > 0 , "Invalid amount");
        require(to != address(0), "to is Zero address");

        require(IERC20(token).transferFrom(_msgSender(), address(this), _amountIn), "Faild TransferFrom");
        uint256 _swapAmountIn = _amountIn * (10000 - SWAP_FEE_0X) / 10000;
        
        require(IERC20(token).approve(spender, _swapAmountIn), "Failed Approve");
        
        uint256 boughtAmount = address(this).balance;

        require(isSwapTargetList[address(swapTarget)], "Faild SwapTarget");
        (bool success,) = swapTarget.call(swapCallData);
        require(success, "SWAP_CALL_FAILED");

        boughtAmount = address(this).balance - boughtAmount;

        payable(to).transfer(boughtAmount);

        require(IERC20(token).transfer(TREASURY, _amountIn - _swapAmountIn), "Faild Transfer");

        emit LogSwapExactTokenForETHOn0x(token, _amountIn, boughtAmount);
    }
    
    function withdraw(address token) external onlyMultiSig nonReentrant {
        require(IERC20(token).balanceOf(address(this)) > 0 || address(this).balance > 0, "Zero Balance!");

        if(address(this).balance > 0) {
            payable(_msgSender()).transfer(address(this).balance);
        }
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        if(balance > 0) {
            require(IERC20(token).transfer(_msgSender(), balance), "Faild Transfer");
        }
        
        emit LogWithdraw(_msgSender(), token, balance, address(this).balance);
    }

    receive() external payable {
        emit LogReceived(_msgSender(), msg.value);
    }

    fallback() external payable { 
        emit LogFallback(_msgSender(), msg.value);
    }

    //-------------------------------------------------------------------------
    // set functions
    //-------------------------------------------------------------------------

    function setPause() external onlyMultiSig {
        _pause();
    }

    function setUnpause() external onlyMultiSig {
        _unpause();
    }

    function setTreasury(address _newTreasury) external onlyMultiSig whenNotPaused {
        require(TREASURY != _newTreasury, "Same address! Must be Multi-sig!");
        TREASURY = _newTreasury;

        emit LogSetTreasury(_msgSender(), TREASURY);
    }

    function setSwapFee(uint256 _newSwapFee) external onlyMultiSig whenNotPaused {
        require(_newSwapFee <= MAX_SWAP_FEE, "SWAP_FEE_MIN_0_MAX_30");
        require(SWAP_FEE != _newSwapFee, "Same value!");
        SWAP_FEE = _newSwapFee;

        emit LogSetSwapFee(_msgSender(), SWAP_FEE);
    }

    function setSwapFee0x(uint256 _newSwapFee0x) external onlyMultiSig whenNotPaused {
        require(_newSwapFee0x <= MAX_SWAP_FEE, "SWAP_FEE_MIN_0_MAX_30");
        require(SWAP_FEE_0X != _newSwapFee0x, "Same value!");
        SWAP_FEE_0X = _newSwapFee0x;

        emit LogSetSwapFee0x(_msgSender(), SWAP_FEE_0X);
    }

    function setDexRouter(address _newRouter) external onlyMultiSig whenNotPaused {
        require(address(dexRouter_) != _newRouter, "Same router!");
        dexRouter_ = IGooseBumpsSwapRouter02(_newRouter);
        
        emit LogSetDexRouter(_msgSender(), address(dexRouter_));
    }

    function updateSwapTargetList(address _swapTarget, bool bValue) external onlyMultiSig whenNotPaused {
        require(isSwapTargetList[_swapTarget] != bValue, "Same value!");
        isSwapTargetList[_swapTarget] = bValue;
        
        emit LogUpdateSwapTargetList(_msgSender(), _swapTarget, bValue);
    }
}
