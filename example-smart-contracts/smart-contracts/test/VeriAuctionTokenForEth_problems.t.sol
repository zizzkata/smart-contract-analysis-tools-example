// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./VeriAuctionTokenForEth_setup.t.sol";

// Attacker
import "./Attackers/VeriAuctionTokenForEth_reentrancy_attacker.sol";

contract VeriAuctionTokenForEth_problems_test is VeriAuctionTokenForEth_problems_setup {
    //========================================
    // setup
    //========================================

    function setUp() public {
        veriAuctionTokenForEth_problems_setup();
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