# Foundry x Fe

A Foundry template to compile and test Fe contracts. 

<img src="https://raw.githubusercontent.com/ethereum/fe/master/logo/fe_svg/fe_source.svg" width="150px">

<br>


# Installation / Setup

To set up Foundry x Fe, first make sure you have [Fe](https://fe-lang.org/) installed. Further make sure to set the `FE_PATH` environment variable to the path of the `fe` executable.

Then set up a new Foundry project with the following command (replacing `fe_project_name` with your new project's name).

```
forge init --template https://github.com/cburgdorf/Foundry-Fe fe_project_name
```


Now you are all set up and ready to go! Below is a quick example of how to set up, deploy and test Fe contracts.


<br>
<br>


# Compiling/Testing Fe Contracts

The FeDeployer is a pre-built contract that takes a filename and deploys the corresponding Fe contract, returning the address that the bytecode was deployed to. If you want, you can check out [how the FeDeployer works under the hood](https://github.com/cburgdorf/Foundry-Fe/blob/main/lib/utils/FeDeployer.sol). Below is a quick example of how to setup and deploy a SimpleStore contract written in Fe.


## SimpleStore.Fe

Here is a simple Fe contract called `SimpleStore.Fe`, which is stored within the `fe_contracts` directory. Make sure to put all of your `.fe` files in the `fe_contracts` directory so that the Fe compiler knows where to look when compiling.

```rust
contract SimpleStore {
    val: u256

    pub fn __init__(mut self, val: u256) {
        self.val = val
    }

    pub fn store(mut self, val: u256) {
        self.val = val;
    }

    pub fn get(self) -> u256 {
        return self.val
    }
}
```

<br>


## SimpleStore Interface

Next, you will need to create an interface for your contract. This will allow Foundry to interact with your Fe contract, enabling the full testing capabilities that Foundry has to offer.

```js

interface SimpleStore {
    function store(uint256 val) external;
    function get() external returns (uint256);
}
```

<br>


## SimpleStore Test

First, the file imports `ISimpleStore.sol` as well as the `Fe.sol` contract.

To deploy the contract, simply create a new instance of `Fe` and call `Fe.deployContract(fileName)` method, passing in the file name of the contract you want to deploy. Additionally, if the contract requires constructor arguments you can pass them in by supplying an abi encoded representation of the constructor arugments, which looks like this `Fe.deployContract(fileName, abi.encode(arg0, arg1, arg2...))`.

In this example, `SimpleStore` is passed in to deploy the `SimpleStore.fe` contract. The `deployContract` function compiles the Fe contract and deploys the newly compiled bytecode, returning the address that the contract was deployed to. Since the `SimpleStore.fe` takes one constructor argument, the argument is wrapped in `abi.encode()` and passed to the `deployContract` function as a second argument.

The deployed address is then used to initialize the ISimpleStore interface. Once the interface has been initialized, your Fe contract can be used within Foundry like any other Solidity contract.

To test any Fe contract deployed with Fe, simply run `forge test`. Since `ffi` is set to `true` in the `foundry.toml` file, you can run `forge test` without needing to pass in the `--ffi` flag. You can also use additional flags as you would with any other Foundry project. For example: `forge test -f <url> -vvvv`.

```js
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "../../lib/ds-test/test.sol";
import "../../lib/utils/Console.sol";
import "../../lib/utils/Fe.sol";

import "../ISimpleStore.sol";

contract SimpleStoreTest is DSTest {

    ISimpleStore simpleStore;

    function setUp() public {
        Fe.compileFile("SimpleStore");

        ///@notice deploy a new instance of ISimplestore by passing in the address of the deployed Fe contract
        simpleStore = ISimpleStore(
            Fe.deployContract("SimpleStore", abi.encode(1234))
        );
    }

    function testGet() public {
        uint256 val = simpleStore.get();

        require(val == 1234);
    }

    function testStore(uint256 _val) public {
        simpleStore.store(_val);
        uint256 val = simpleStore.get();

        require(_val == val);
    }
}
```


<br>

# Compiling Fe ingots

Fe code can easily be splitted across multiple files via [ingots](https://fe-lang.org/docs/release_notes.html?highlight=ingot#features-11). The `Fe` helper supports compiling ingots via `Fe.compileIngot(ingotName)`.

Check the `BasicIngot` example for more details.



# Other Foundry Integrations

- [Foundry-Vyper](https://github.com/0xKitsune/Foundry-Vyper) 
- [Foundry-Huff](https://github.com/0xKitsune/Foundry-Huff)
- [Foundry-Yul+](https://github.com/ControlCplusControlV/Foundry-Yulp)
