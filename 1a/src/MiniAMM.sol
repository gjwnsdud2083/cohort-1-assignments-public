// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IMiniAMM, IMiniAMMEvents} from "./IMiniAMM.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Add as many variables or functions as you would like
// for the implementation. The goal is to pass `forge test`.
contract MiniAMM is IMiniAMM, IMiniAMMEvents {
    uint256 public k = 0;
    uint256 public xReserve = 0;
    uint256 public yReserve = 0;

    address public tokenX;
    address public tokenY;

    // implement constructor
    constructor(address _tokenX, address _tokenY) {
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

    modifier nonZeroAmounts(uint256 xAmountIn, uint256 yAmountIn) {
    require(xAmountIn > 0 && yAmountIn > 0, "Amounts must be greater than 0");
    _;
    }

    function _pullBoth(uint256 xIn, uint256 yIn) internal {
        IERC20(tokenX).transferFrom(msg.sender, address(this), xIn);
        IERC20(tokenY).transferFrom(msg.sender, address(this), yIn);
    }

    function _applyAdd(uint256 xIn, uint256 yIn) internal {
        xReserve += xIn;
        yReserve += yIn;
        k = xReserve * yReserve;
        emit AddLiquidity(xIn, yIn);
    }

    // add parameters and implement function.
    // this function will determine the initial 'k'.
    function _addLiquidityFirstTime(uint256 _xAmountIn, uint256 _yAmountIn) internal nonZeroAmounts(_xAmountIn, _yAmountIn) {
        _pullBoth(_xAmountIn, _yAmountIn);
        _applyAdd(_xAmountIn, _yAmountIn);
    }

    // add parameters and implement function.
    // this function will increase the 'k'
    // because it is transferring liquidity from users to this contract.
    function _addLiquidityNotFirstTime(uint256 _xAmountIn, uint256 _yAmountIn) internal nonZeroAmounts(_xAmountIn, _yAmountIn) {
        uint256 yRequired = (_xAmountIn * yReserve) / xReserve;
        require(_yAmountIn == yRequired, "Invalid ratio");
        _pullBoth(_xAmountIn, yRequired);
        _applyAdd(_xAmountIn, yRequired);
    }

    // complete the function
    function addLiquidity(uint256 xAmountIn, uint256 yAmountIn) external {
        if (k == 0) {
            // add params
            _addLiquidityFirstTime(xAmountIn, yAmountIn);
        } else {
            // add params
            _addLiquidityNotFirstTime(xAmountIn, yAmountIn);
        }
    }

    // complete the function
    function swap(uint256 xAmountIn, uint256 yAmountIn) external {
        require(k > 0, "No liquidity in pool");                         
        require(!(xAmountIn == 0 && yAmountIn == 0), "Must swap at least one token"); 
        require(!(xAmountIn > 0 && yAmountIn > 0), "Can only swap one direction at a time"); 
        if (xAmountIn > 0) {
            require(xAmountIn <= xReserve, "Insufficient liquidity");
            IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
            uint256 yOut = yReserve - (k / (xReserve + xAmountIn));
            IERC20(tokenY).transfer(msg.sender, yOut);
            xReserve += xAmountIn;
            yReserve -= yOut;
            emit Swap(xAmountIn, yOut);
        } else {
            require(yAmountIn <= yReserve, "Insufficient liquidity");
            IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountIn);
            uint256 xOut = xReserve - (k / (yReserve + yAmountIn));
            IERC20(tokenX).transfer(msg.sender, xOut);
            yReserve += yAmountIn;
            xReserve -= xOut;
            emit Swap(xOut, yAmountIn);
        }
    }
}
