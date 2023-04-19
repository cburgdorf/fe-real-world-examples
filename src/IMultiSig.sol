// SPDX-License-Identifier: MIT
pragma abicoder v2;

interface IMultiSig {
    
    function foo() external returns (uint256);
    function execute(address destination, uint256 value, bytes memory data, uint16 length) external;
    function execute_transaction(uint256 tx_id) external;
    function add_transaction(address destination, uint256 value, bytes memory data, uint16 length) external returns (uint256);
    function transfer_example(bytes memory data) external;

}
