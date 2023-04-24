// SPDX-License-Identifier: UNLICENSED
//pragma solidity ^0.8.19;
pragma abicoder v2;

import '../../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol';
import 'forge-std/Test.sol';
import '../../lib/utils/Fe.sol';
import '../IMultiSig.sol';

address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
// Binance wallet with DAI
address constant BINANCE_ACCOUNT = 0x28C6c06298d514Db089934071355E5743bf21d60;

function pad_to_length(bytes memory data, uint256 length) pure returns (bytes memory) {
    bytes memory padded_data = new bytes(length);
    for (uint256 i = 0; i < data.length; i++) {
        padded_data[i] = data[i];
    }
    return padded_data;
}

uint16 constant DATA_LENGTH = 128;

contract MultiSigTest is Test {
    IMultiSig public multisig;

    function setUp() public {
        Fe.compileIngot("multisig");
        address[50] memory owners;
        owners[0] = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;
        multisig = IMultiSig(Fe.deployContract("MultiSig", abi.encode(owners, 1)));
    }

    function testExecute() public {
      bytes memory data = pad_to_length(hex"a9059cbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", DATA_LENGTH);

      address multisig_address = address(multisig);
      vm.startPrank(BINANCE_ACCOUNT);
      IERC20(DAI).transfer(address(multisig), 10000);
      uint256 initial_multisig_balance = IERC20(DAI).balanceOf(multisig_address);
      multisig.execute(DAI, 0, data, 68);

      uint256 second_multisig_balance = IERC20(DAI).balanceOf(multisig_address);
      assertEq(second_multisig_balance, initial_multisig_balance - 1);
    }

    function testAdd() public {
      // Send some DAI to the 0x0 address
      bytes memory data = pad_to_length(hex"a9059cbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", DATA_LENGTH);
      uint256 tx_id = multisig.add_transaction(DAI, 0, data, 68);
      assertEq(tx_id, 0);
      uint256 second_tx_id = multisig.add_transaction(DAI, 0, data, 68);
      assertEq(second_tx_id, 1);
    }

    function testExecuteTx() public {
      bytes memory data = pad_to_length(hex"a9059cbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", DATA_LENGTH);

      address multisig_address = address(multisig);
      vm.startPrank(BINANCE_ACCOUNT);
      IERC20(DAI).transfer(address(multisig), 10000);
      uint256 initial_multisig_balance = IERC20(DAI).balanceOf(multisig_address);

      vm.stopPrank();
      vm.startPrank(0x627306090abaB3A6e1400e9345bC60c78a8BEf57);
      uint256 tx_id = multisig.add_transaction(DAI, 0, data, 68);
      multisig.confirm_transaction(tx_id);

      uint256 second_multisig_balance = IERC20(DAI).balanceOf(multisig_address);
      assertEq(second_multisig_balance, initial_multisig_balance - 1);
    }


    function testTx() public {
      //bytes memory data = new bytes(1);
      //multisig.execute(address(0x0), 0, data, 1);
      //assertEq(multisig.foo(), 5);
    }
}
