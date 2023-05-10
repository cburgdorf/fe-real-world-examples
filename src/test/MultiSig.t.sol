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
address constant FIRST_OWNER = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;
address constant SECOND_OWNER = 0x527306090ABaB3a6e1400e9345BC60C78A8Bef57;
address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

contract MultiSigTest is Test {

    // We have to declare the events that we want add assertions for
    event Confirmation(address indexed owner, uint indexed tx_id);
    event Submission(uint indexed tx_id);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);

    IMultiSig public multisig;

    function setUp() public {
        Fe.compileIngot("multisig");
        address[50] memory owners;
        owners[0] = FIRST_OWNER;
        owners[1] = SECOND_OWNER;
        multisig = IMultiSig(Fe.deployContract("MultiSig", abi.encode(owners, 2)));
    }

    function testCannotCallAddOwner() public {
      vm.expectRevert();
      multisig.add_owner(BINANCE_ACCOUNT);
    }


    function testAddAndRemoveOwner() public {
      bytes memory data = pad_to_length(hex"4a75e74100000000000000000000000028c6c06298d514db089934071355e5743bf21d60", DATA_LENGTH);
      vm.startPrank(FIRST_OWNER);
      address[50] memory existing_owners = multisig.get_owners();
      assertEq(existing_owners[0], FIRST_OWNER);
      assertEq(existing_owners[1], SECOND_OWNER);
      assertEq(existing_owners[2], ZERO_ADDRESS);

      uint256 tx_id = multisig.submit_transaction(address(multisig), 0, data, 36);
      vm.stopPrank();

      vm.expectEmit(true, true, true, true);
      emit OwnerAddition(BINANCE_ACCOUNT);

      vm.startPrank(SECOND_OWNER);
      multisig.confirm_transaction(tx_id);

      address[50] memory new_owners = multisig.get_owners();
      assertEq(new_owners[0], FIRST_OWNER);
      assertEq(new_owners[1], SECOND_OWNER);
      assertEq(new_owners[2], BINANCE_ACCOUNT);

      bytes memory data_removal = pad_to_length(hex"f6b9571a00000000000000000000000028c6c06298d514db089934071355e5743bf21d60", DATA_LENGTH);
      uint256 tx2_id = multisig.submit_transaction(address(multisig), 0, data_removal, 36);
      vm.stopPrank();

      vm.startPrank(FIRST_OWNER);
      vm.expectEmit(true, true, true, true);
      emit OwnerRemoval(BINANCE_ACCOUNT);

      multisig.confirm_transaction(tx2_id);
      assertEq(existing_owners[0], FIRST_OWNER);
      assertEq(existing_owners[1], SECOND_OWNER);
      assertEq(existing_owners[2], ZERO_ADDRESS);
    }

    function testReplaceOwner() public {
      bytes memory data = pad_to_length(hex"f097d1de000000000000000000000000527306090abab3a6e1400e9345bc60c78a8bef5700000000000000000000000028c6c06298d514db089934071355e5743bf21d60", DATA_LENGTH);
      vm.startPrank(FIRST_OWNER);
      address[50] memory existing_owners = multisig.get_owners();
      assertEq(existing_owners[0], FIRST_OWNER);
      assertEq(existing_owners[1], SECOND_OWNER);
      assertEq(existing_owners[2], ZERO_ADDRESS);

      uint256 tx_id = multisig.submit_transaction(address(multisig), 0, data, 68);
      vm.stopPrank();

      vm.expectEmit(true, true, true, true);
      emit OwnerRemoval(SECOND_OWNER);
      emit OwnerAddition(BINANCE_ACCOUNT);

      vm.startPrank(SECOND_OWNER);
      multisig.confirm_transaction(tx_id);

      address[50] memory new_owners = multisig.get_owners();
      assertEq(new_owners[0], FIRST_OWNER);
      assertEq(new_owners[1], BINANCE_ACCOUNT);
      assertEq(new_owners[2], ZERO_ADDRESS);
    }

    function testSubmit() public {
      // Send some DAI to the 0x0 address
      bytes memory data = pad_to_length(hex"a9059cbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", DATA_LENGTH);
      vm.startPrank(FIRST_OWNER);
      vm.expectEmit(true, true, true, true);
      uint256 tx_id = multisig.submit_transaction(DAI, 0, data, 68);
      emit Submission(tx_id);
      assertEq(tx_id, 0);
      vm.expectEmit(true, true, true, true);
      uint256 second_tx_id = multisig.submit_transaction(DAI, 0, data, 68);
      emit Submission(second_tx_id);
      assertEq(second_tx_id, 1);
    }

    function testStrangersCannotSubmit() public {
      // Send some DAI to the 0x0 address
      bytes memory data = pad_to_length(hex"a9059cbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", DATA_LENGTH);
      vm.expectRevert();
      multisig.submit_transaction(DAI, 0, data, 68);
    }

    function testExecuteTx() public {
      bytes memory data = pad_to_length(hex"a9059cbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", DATA_LENGTH);

      address multisig_address = address(multisig);
      vm.startPrank(BINANCE_ACCOUNT);
      IERC20(DAI).transfer(address(multisig), 10000);
      uint256 initial_multisig_balance = IERC20(DAI).balanceOf(multisig_address);

      vm.expectEmit(true, true, true, true);
      emit Confirmation(FIRST_OWNER, 0);
      vm.stopPrank();
      vm.startPrank(FIRST_OWNER);
      uint256 tx_id = multisig.submit_transaction(DAI, 0, data, 68);

      vm.expectEmit(true, true, true, true);
      emit Confirmation(SECOND_OWNER, 0);
      vm.stopPrank();
      vm.startPrank(SECOND_OWNER);
      multisig.confirm_transaction(tx_id);

      uint256 second_multisig_balance = IERC20(DAI).balanceOf(multisig_address);
      assertEq(second_multisig_balance, initial_multisig_balance - 1);
    }

    function testCanNotExecuteUnconfirmedTx() public {
      bytes memory data = pad_to_length(hex"a9059cbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", DATA_LENGTH);

      address multisig_address = address(multisig);
      vm.startPrank(BINANCE_ACCOUNT);
      IERC20(DAI).transfer(address(multisig), 10000);
      uint256 initial_multisig_balance = IERC20(DAI).balanceOf(multisig_address);

      vm.expectEmit(true, true, true, true);
      emit Confirmation(FIRST_OWNER, 0);

      vm.stopPrank();
      vm.startPrank(FIRST_OWNER);
      uint256 tx_id = multisig.submit_transaction(DAI, 0, data, 68);

      multisig.execute_transaction(tx_id);
      uint256 second_multisig_balance = IERC20(DAI).balanceOf(multisig_address);
      // Balance is still the same
      assertEq(second_multisig_balance, initial_multisig_balance);
    }


}
