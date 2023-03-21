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
