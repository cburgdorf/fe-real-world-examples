// SPDX-License-Identifier: UNLICENSED
//pragma solidity ^0.8.19;
pragma solidity =0.7.6;
pragma abicoder v2;

import '../../node_modules/@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '../../node_modules/@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

import '../../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol';
import 'forge-std/Test.sol';
import '../../lib/utils/Fe.sol';
import '../ISwapper.sol';

ISwapRouter constant SwapRouterAddress = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

// Binance wallet with DAI
address constant BINANCE_ACCOUNT = 0x28C6c06298d514Db089934071355E5743bf21d60;

contract SwapTest is Test {
    ISwapper public swapper;

    function setUp() public {
        Fe.compileIngot("defi");
        swapper = ISwapper(Fe.deployContract("SwapExamples", abi.encode(SwapRouterAddress)));
    }

    function testSwap() public {

      // Impersonate Binance account
      vm.startPrank(BINANCE_ACCOUNT);

      // Remember the initial balances
      uint256 initial_dai_balance = IERC20(DAI).balanceOf(BINANCE_ACCOUNT);
      uint256 initial_weth_balance = IERC20(WETH9).balanceOf(BINANCE_ACCOUNT);
      console.log("initial_dai_balance", initial_dai_balance);
      console.log("initial_weth_balance", initial_weth_balance);

      // Approve and swap
      IERC20(DAI).approve(address(swapper), 9000000);
      uint256 amount_dai = 100_000;
      uint256 amount_out = swapper.swap_exact_input_single(amount_dai);

      // Check new balances and report
      uint256 new_dai_balance = IERC20(DAI).balanceOf(BINANCE_ACCOUNT);
      uint256 new_weth_balance = IERC20(WETH9).balanceOf(BINANCE_ACCOUNT);
      console.log("new_dai_balance", new_dai_balance);
      console.log("new_weth_balance", new_weth_balance);
      assertEq(new_dai_balance, initial_dai_balance - amount_dai);
      assert(new_weth_balance > initial_weth_balance);
      assertEq(new_weth_balance, initial_weth_balance + amount_out);
    }

    function testLackOfContractCodeReverts() public {
      uint256 amount_dai = 100_000;
      ISwapper broken_swapper = ISwapper(Fe.deployContract("SwapExamples", abi.encode(address(0x0))));
      try broken_swapper.swap_exact_input_single(amount_dai) {
        // Call should revert if returndata is empty
        assert(false);
      } catch {

      }
    }
}
