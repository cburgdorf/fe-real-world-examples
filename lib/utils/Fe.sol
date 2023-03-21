// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

///@notice This cheat codes interface is named _CheatCodes so you can use the CheatCodes interface in other testing files without errors
interface _CheatCodes {
    function ffi(string[] calldata) external returns (bytes memory);
    function envString(string calldata key) external returns (string memory);
}

address constant HEVM_ADDRESS = address(bytes20(uint160(uint256(keccak256("hevm cheat code")))));
_CheatCodes constant cheatCodes = _CheatCodes(HEVM_ADDRESS);


library Fe {
    ///@notice Compiles a single Fe file
    ///@param fileName - The file name without the .fe extension. For example, the file name for "SimpleStore.fe" is "SimpleStore"
    function compileFile(string memory fileName) public {
        string[] memory compile_cmds = new string[](4);
        compile_cmds[0] = cheatCodes.envString("FE_PATH");
        compile_cmds[1] = "build";
        compile_cmds[2] = "--overwrite";
        compile_cmds[3] = string.concat("fe_contracts/", fileName, ".fe");
        cheatCodes.ffi(compile_cmds);
    }

    ///@notice Compiles a Fe ingot
    ///@param ingotName - The ingot name
    function compileIngot(string memory ingotName) public {
        string[] memory compile_cmds = new string[](4);
        compile_cmds[0] = cheatCodes.envString("FE_PATH");
        compile_cmds[1] = "build";
        compile_cmds[2] = "--overwrite";
        compile_cmds[3] = string.concat("fe_contracts/", ingotName);
        cheatCodes.ffi(compile_cmds);
    }

    ///@notice Compiles a Fe contract and returns the address that the contract was deployeod to
    ///@notice If deployment fails, an error will be thrown
    ///@param contractName - The name of the Fe contract.
    ///@return deployedAddress - The address that the contract was deployed to

    function deployContract(string memory contractName) public returns (address) {
        string[] memory cmds = new string[](2);
        cmds[0] = "cat";
        cmds[1] = string.concat("output/", contractName, "/", contractName, ".bin");

        ///@notice compile the Fe contract and return the bytecode
        bytes memory bytecode = cheatCodes.ffi(cmds);

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(
            deployedAddress != address(0),
            "FeDeployer could not deploy contract"
        );

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }

    ///@notice Compiles a Fe contract with constructor arguments and returns the address that the contract was deployeod to
    ///@notice If deployment fails, an error will be thrown
    ///@param contractName - The file name of the Fe contract.
    ///@return deployedAddress - The address that the contract was deployed to
    function deployContract(string memory contractName, bytes calldata args)
        public
        returns (address)
    {
        string[] memory cmds = new string[](2);
        cmds[0] = "cat";
        cmds[1] = string.concat("output/", contractName, "/", contractName, ".bin");

        ///@notice compile the Fe contract and return the bytecode
        bytes memory _bytecode = cheatCodes.ffi(cmds);

        //add args to the deployment bytecode
        bytes memory bytecode = abi.encodePacked(_bytecode, args);

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(
            deployedAddress != address(0),
            "FeDeployer could not deploy contract"
        );

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }
}
