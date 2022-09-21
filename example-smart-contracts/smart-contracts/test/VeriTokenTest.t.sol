// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "Utils/Utils.sol";
import "src/VeriToken.sol";

contract VeriTokenTest is Test {
    Utils utils;
    VeriToken token;

    function setUp() public {
        // vm comes from Test -> Script
        utils = new Utils(vm);
        token = new VeriToken();
    }
}
