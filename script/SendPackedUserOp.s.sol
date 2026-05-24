// SPDX -License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "lib/forge-std/src/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "script/HelperConfig.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;

    function run() public {}

    function generateSignedUserOperation(bytes memory callData, HelperConfig.NetworkConfig memory config)
        public
        view
        returns (PackedUserOperation memory)
    {
        //1. Generate data
        uint256 nonce = vm.getNonce(config.account);
        PackedUserOperation memory unsignedUserOp = _generateUserOperation(callData, config.account, nonce);
        //2. Get userOpHash
        bytes32 userOpHash = IEntryPoint(config.entryPoint).getUserOpHash(unsignedUserOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        //2. Sign the data
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        if (block.chainid == 31337) {
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        } else {
            (v, r, s) = vm.sign(config.account, digest);
        }
        PackedUserOperation memory userSignedOperation = unsignedUserOp;
        userSignedOperation.signature = abi.encodePacked(r, s, v);
        return userSignedOperation;
    }

    function _generateUserOperation(bytes memory callData, address sender, uint256 nonce)
        internal
        pure
        returns (PackedUserOperation memory)
    {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;
        return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: hex"",
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }
}
