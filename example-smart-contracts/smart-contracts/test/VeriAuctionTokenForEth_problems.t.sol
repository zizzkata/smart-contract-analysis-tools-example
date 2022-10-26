// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Utils/Utils.sol";
import "./Mocks/ERC20Mock.sol";

// Contract Under Test
import "src/VeriAuctionTokenForEth_problems.sol";

// Attacker
import "./Attackers/VeriAuctionTokenForEth_reentrancy_attacker.sol";

contract VeriAuctionTokenForEth_problems_test is Test {
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

    function setUp() public {
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

    //========================================
    // tests
    //========================================
    
    //====================
    // commitTokens()
    //====================

    function testCommitTokensUpdatesCommitment(uint256 ethToCommit) public {        
        // Setup
        vm.assume(ethToCommit > 0);
        vm.assume(type(uint256).max / 10**token.decimals() >= ethToCommit);

        vm.deal(alice, ethToCommit);
        
        // Execute
        vm.prank(alice);
        veriAuction.commitEth{value: ethToCommit}();

        // Test
        vm.prank(alice);
        uint256 commitedAmount = veriAuction.getCommitment();

        assertEq(commitedAmount, ethToCommit);   
    }
}