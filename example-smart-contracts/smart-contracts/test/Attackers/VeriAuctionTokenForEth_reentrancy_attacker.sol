// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
pragma abicoder v2;

import "../../src/interfaces/IVeriAuctionTokenForEth.sol";

contract VeriAuctionTokenForEth_reentrancy_attacker {
    //========================================
    // Variables
    //========================================

    uint256 timesToAttack;

    //========================================
    // constructor
    //========================================

    constructor(uint256 _timesToAttack) {
        timesToAttack = _timesToAttack;
    }

    function setTimesToAttack(uint256 times) external {
        timesToAttack = times;
    }

    //========================================
    // functions
    //========================================

    fallback () external payable {
        if(timesToAttack > 0) {
            timesToAttack--;
            (bool success, ) = msg.sender.call(abi.encodeWithSelector(IVeriAuctionTokenForEth.resignFromAuction.selector));
            require(success, "Failed to attack");
        }
    }
}