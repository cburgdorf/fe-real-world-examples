// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

interface ISwapper {
    function swap_exact_input_single(uint256 amountIn) external returns (uint256);
}
