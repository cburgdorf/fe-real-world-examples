# Fe realworld examples

A bunch of Fe realworld examples.

<img src="https://raw.githubusercontent.com/ethereum/fe/master/logo/fe_svg/fe_source.svg" width="150px">

<br>


# Prerequisite
# Installation / Setup

To set up Foundry x Fe, first make sure you have [Fe](https://fe-lang.org/) installed. Further make sure to set the `FE_PATH` environment variable to the path of the `fe` executable.

Then follow the [Foundry installation guide](https://book.getfoundry.sh/getting-started/installation) to install Foundry.

Set up an environment variable `MAINNET_JSON_RPC` to point to a mainnet node. For example, you can use [Alchemy](https://alchemyapi.io/) or [Infura](https://infura.io/).

# Run the examples

Run `forge test --fork-url $MAINNET_JSON_RPC`

## UniswapV3 Swap with Fe


```rust
    pub fn swap_exact_input_single(mut self, mut ctx: Context, amountIn: u256) -> u256 {
        // msg.sender must approve this contract

        // Transfer the specified amount of DAI to this contract.
        //TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountIn);
        self.DAI.transferFrom(ctx, sender: ctx.msg_sender(), recipient: ctx.self_address(), value: amountIn)
        

        // // Approve the router to spend DAI.
        // //TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);
        self.DAI.approve(ctx, spender: address(self.swapRouter), value: amountIn)


        // // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        
         let params: ExactInputSingleParams = ExactInputSingleParams(
             tokenIn: address(self.DAI),
             tokenOut: address(self.WETH9),
             fee: 3000,
             recipient: ctx.msg_sender(),
             deadline: ctx.block_timestamp(),
             amountIn: amountIn,
             amountOutMinimum: 0,
             sqrtPriceLimitX96: 0,
         );

        unsafe {
            return self.handle_swap(params)
        }
    }
```
