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
        // Setup
        veriAuction.commitEth{value: 1 ether}();
        
        // Execute

        // Test
    }

    function testReentrancyResignFromAuctionAndClaimTokensOnFinalizedAuction() public {        
        // Setup
        
        // Execute

        // Test
    }
}