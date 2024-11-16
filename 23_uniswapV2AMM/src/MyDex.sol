//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./IDex.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
contract MyDex is IDex {

    IUniswapV2Router02 private _router;
//    address private _factoryAddress;

    constructor(address router) {
        _router = IUniswapV2Router02(router);
//        _factoryAddress = factoryAddress;
    }

    function sellETH(address buyToken, uint256 minBuyAmount) external payable {
        address[] memory path = new address[](2);
        path[0] = _router.WETH();
        path[1] = buyToken;
        _router.swapExactETHForTokens{value: msg.value}(minBuyAmount, path, msg.sender, block.timestamp + 60);
    }

    function buyETH(address sellToken, uint256 sellAmount, uint256 minBuyAmount) external {
        IERC20(sellToken).transferFrom(msg.sender,address (this),sellAmount);
        IERC20(sellToken).approve(address (_router),sellAmount);
        address[] memory path = new address[](2);
        path[0] = sellToken;
        path[1] = _router.WETH();
        _router.swapExactTokensForETH(sellAmount, minBuyAmount, path, msg.sender, block.timestamp + 60);
    }

    function addLiquidityETH (
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity) {
        IERC20(token).transferFrom(msg.sender,address (this),amountTokenDesired);
        IERC20(token).approve(address (_router),amountTokenDesired);
        return _router.addLiquidityETH{value: msg.value}(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH) {
        return _router.removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline + 60);
    }

    function getAmountsOut(uint amountIn, address[] memory path) public view virtual returns (uint[] memory amounts) {
        return _router.getAmountsOut(amountIn, path);
    }

    receive() external payable{}
}