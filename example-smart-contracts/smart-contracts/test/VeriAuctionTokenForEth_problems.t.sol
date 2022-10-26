// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./VeriAuctionTokenForEth_setup.t.sol";

contract VeriAuctionTokenForEth_problems_test is VeriAuctionTokenForEth_problems_setup {
    //========================================
    // Variables
    //========================================
    

    //========================================
    // Setup
    //========================================

    function setUp() public {
        veriAuctionTokenForEth_problems_setup();
    }

    //========================================
    // Helpers
    //========================================

    function commitEthToAuction(address user, uint256 ethToCommit) internal {
        vm.assume(ethToCommit > 0);
        vm.assume(type(uint256).max / 10**token.decimals() >= ethToCommit);

        vm.deal(user, ethToCommit);
        vm.prank(user);
        veriAuction.commitEth{value: ethToCommit}();
    }

    function isPayable(address testAddress) internal returns (bool) {
        if(payable(testAddress).send(0)) {
            return true;
        }
        return false;
    }

    //========================================
    // Tests
    //========================================
    
    //====================
    // commitTokens()
    //
    // TODO: Add more tests of edge cases and reverting paths
    //====================

    function testCommitTokensUpdatesCommitment(uint256 ethToCommit) public {        
        //----------
        // Setup
        //----------

        vm.assume(ethToCommit > 0);
        vm.assume(type(uint256).max / 10**token.decimals() >= ethToCommit);

        vm.deal(alice, ethToCommit);
        
        //----------
        // Execute
        //----------
        
        vm.prank(alice);
        veriAuction.commitEth{value: ethToCommit}();

        //----------
        // Test
        //----------
        
        vm.prank(alice);
        uint256 commitedAmount = veriAuction.getCommitment();

        assertEq(commitedAmount, ethToCommit);   
    }

    //====================
    // resignFromAuction()
    //
    // TODO: Add more tests of edge cases and reverting paths
    //====================

    function testResignFromAuctionWhenAuctionNotFinalReturnsEth(address payable commiter, uint256 ethToCommit) public {
        //----------
        // Setup
        //----------

        vm.assume(isPayable(commiter));
        vm.assume(commiter != address(utils));
        vm.assume(commiter != address(token));
        vm.assume(commiter != address(veriAuction));

        commitEthToAuction(commiter, ethToCommit);
        uint256 initialAuctionEthBalance = address(veriAuction).balance;
        assertEq(initialAuctionEthBalance, ethToCommit, "testResignFromAuctionWhenAuctionNotFinalReturnsEth: commitEthToAuction() does not work as expected");


        uint256 initialCommiterEthBalance = commiter.balance;

        //----------
        // Execute
        //----------

        vm.prank(commiter);
        veriAuction.resignFromAuction();

        //----------
        // Test
        //----------

        uint256 newAuctionEthBalance = address(veriAuction).balance;
        assertEq(initialAuctionEthBalance - ethToCommit, newAuctionEthBalance);

        uint256 newCommiterEthBalance = commiter.balance;
        assertEq(initialCommiterEthBalance + ethToCommit, newCommiterEthBalance);
    }
}