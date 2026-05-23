// SPDX -License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "lib/forge-std/src/Script.sol";
import {MinimalAccount} from "src/MinimalAccount.sol";
import {HelperConfig} from "script/HelperConfig.sol";

contract DeployMinimal is Script {
    function run() external {}

    function deployMinimalAccount() public returns (HelperConfig, MinimalAccount) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        vm.startBroadcast(config.account);
        MinimalAccount minimalAccount = new MinimalAccount(config.entryPoint);
        minimalAccount.transferOwnership(msg.sender);
        vm.stopBroadcast();
        return (helperConfig, minimalAccount);
    }
}
