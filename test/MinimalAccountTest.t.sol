// SPDX -License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "lib/forge-std/src/Test.sol";
import {MinimalAccount} from "src/MinimalAccount.sol";
import {DeployMinimal} from "script/DeployMinimal.s.sol";
import {HelperConfig} from "script/HelperConfig.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp} from "script/SendPackedUserOp.s.sol";

contract MinimalAccountTest is Test {
    DeployMinimal deployMinimal;
    HelperConfig helperConfig;
    ERC20Mock usdc;
    MinimalAccount minimalAccount;
    address user;
    SendPackedUserOp sendPackedUserOp;

    uint256 constant AMOUNT = 1e18;

    function setUp() public {
        user = makeAddr("user");
        deployMinimal = new DeployMinimal();
        usdc = new ERC20Mock();
        (helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();
    }

    function testOwnerCanExecute() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        minimalAccount.execute(dest, value, functionData);
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    function testNotOwnerCannotExecute() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        vm.prank(user);
        minimalAccount.execute(dest, value, functionData);
    }

    function testRecoverUserOperation() public {}
}
