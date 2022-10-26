// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Utils/Utils.sol";
import "./Mocks/ERC20Mock.sol";

// Contract Under Test
import "src/VeriAuctionTokenForEth_problems.sol";

contract VeriAuctionTokenForEth_problems_setup is Test {
    //========================================
    // Events
    //========================================
    event Commited(address indexed user, uint256 amount, uint256 totalCommited, uint256 newPrice);
    event Claimed(address indexed user, uint256 amount, uint256 price);

    //========================================
    // Variables
    //========================================
    Utils utils;
    VeriAuctionTokenForEth veriAuction;

    ERC20Mock token;
    uint256 amountOfTokensToDistribute;

    address alice;

    //========================================
    // setup
    //========================================

    function veriAuctionTokenForEth_problems_setup() public {
        // vm comes from Test -> Script
        utils = new Utils(vm);
        token = new ERC20Mock();

        amountOfTokensToDistribute = 1_000_000 * 10**token.decimals();
        token.mint(amountOfTokensToDistribute);

        veriAuction = new VeriAuctionTokenForEth(address(token), amountOfTokensToDistribute);

        token.approve(address(veriAuction), amountOfTokensToDistribute);
        veriAuction.depositAuctionTokens();

        address payable[] memory users = utils.createUsers(1);
        alice = users[0];
        vm.label(alice, "Alice");
    }
}