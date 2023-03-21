// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "../../lib/ds-test/test.sol";
import "../../lib/utils/Console.sol";
import "../../lib/utils/Fe.sol";

import "../IFoo.sol";

contract BasicIngotTest is DSTest {

    IFoo foo;

    function setUp() public {
        Fe.compileIngot("basic_ingot");

        foo = IFoo(Fe.deployContract("Foo"));
    }

    function testFoo() public {
        uint256 val = foo.create_bing_contract();
        assertEq(val, 90);
    }
}