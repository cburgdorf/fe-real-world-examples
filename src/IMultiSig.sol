// SPDX-License-Identifier: MIT
pragma abicoder v2;

interface IMultiSig {
    function execute(address destination, uint256 value, bytes memory data, uint16 length) external;
    function execute_transaction(uint256 tx_id) external;
    function confirm_transaction(uint256 tx_id) external;
    function revoke_confirmation(uint256 tx_id) external;
    function submit_transaction(address destination, uint256 value, bytes memory data, uint16 length) external returns (uint256);
    function add_owner(address owner) external;
    function get_owners() external view returns (address[50] memory);
    function get_confirmations(uint256 tx_id) external view returns (address[50] memory);
}


