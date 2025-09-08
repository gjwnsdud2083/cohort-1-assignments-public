// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IMiniAMM, IMiniAMMEvents} from "./IMiniAMM.sol";
import {MiniAMMLP} from "./MiniAMMLP.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Add as many variables or functions as you would like
// for the implementation. The goal is to pass `forge test`.
contract MiniAMM is IMiniAMM, IMiniAMMEvents, MiniAMMLP {
    uint256 public k = 0;
    uint256 public xReserve = 0;
    uint256 public yReserve = 0;

    address public tokenX;
    address public tokenY;

    // implement constructor
    constructor(address _tokenX, address _tokenY) MiniAMMLP(_tokenX, _tokenY) {
         // 1. check if tokenX or tokenY is zero address
        if (_tokenX == address(0)) {
            revert("tokenX cannot be zero address");
        }
        if (_tokenY == address(0)) {
            revert("tokenY cannot be zero address");
        }
        // 2. check if tokens are different
        if (_tokenX == _tokenY) {
            revert("Tokens must be different");
        }
        // 3. set tokenX and tokenY(order matters)
        if (_tokenX < _tokenY) {    
            tokenX = _tokenX;
            tokenY = _tokenY;
        } else {
            tokenX = _tokenY;
            tokenY = _tokenX;
        }
    }

    // Helper function to calculate square root
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    // add parameters and implement function.
    // this function will determine the 'k'.
    function _addLiquidityFirstTime(uint256 xAmountIn, uint256 yAmountIn) internal returns (uint256 lpMinted) {
        IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
        IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountIn);
        xReserve += xAmountIn;
        yReserve += yAmountIn;
        k = xReserve * yReserve;
        lpMinted = sqrt(xReserve * yReserve);
        _mintLP(msg.sender, lpMinted);
        emit AddLiquidity(xAmountIn, yAmountIn);

        return lpMinted;
    }

    // add parameters and implement function.
    // this function will increase the 'k'
    // because it is transferring liquidity from users to this contract.
    function _addLiquidityNotFirstTime(uint256 xAmountIn) internal returns (uint256 lpMinted) {
        uint256 yRequired = (xAmountIn * yReserve) / xReserve;
        
        // Calculate LP tokens BEFORE updating reserves
        lpMinted = (xAmountIn * totalSupply()) / xReserve;
        
        IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
        IERC20(tokenY).transferFrom(msg.sender, address(this), yRequired);
        xReserve += xAmountIn;
        yReserve += yRequired;
        k = xReserve * yReserve;
        
        _mintLP(msg.sender, lpMinted);
        emit AddLiquidity(xAmountIn, yRequired);

        return lpMinted;
    }

    // complete the function. Should transfer LP token to the user.
    function addLiquidity(uint256 xAmountIn, uint256 yAmountIn) external returns (uint256 lpMinted) {
        if (k == 0) {
            return _addLiquidityFirstTime(xAmountIn, yAmountIn);
        } else {
            return _addLiquidityNotFirstTime(xAmountIn);
        }
    }

    // Remove liquidity by burning LP tokens
    function removeLiquidity(uint256 lpAmount) external returns (uint256 xAmount, uint256 yAmount) {
    }

    // complete the function
    function swap(uint256 xAmountIn, uint256 yAmountIn) external {
    }
}
