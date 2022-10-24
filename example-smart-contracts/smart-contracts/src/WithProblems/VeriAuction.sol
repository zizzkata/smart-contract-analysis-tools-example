// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract VeriAuction is Ownable {

    //======================================================
    // Events
    //======================================================
    event Commited(address indexed user, uint256 amount, uint256 totalCommited, uint256 newPrice);
    event Withdrawn(address indexed user, uint256 amount, uint256 price);

    //======================================================
    // Variables
    //======================================================
    IERC20 public auctionToken;

    mapping (address => uint256) private commited;
    uint256 public immutable amountToDistribute;
    bool auctionFinalized;

    //======================================================
    // constructor
    //======================================================

    constructor(address veriTokenAddress, uint256 _amountToDistribute) Ownable() {
        auctionToken = IERC20(veriTokenAddress);
        amountToDistribute = _amountToDistribute;
        auctionFinalized = false;
    }

    //======================================================
    // functions
    //======================================================

 
    function commit() payable external {
        require(msg.value > 0, "VeriAuction (commit): commitment must be greater than 0");

        commited[msg.sender] += msg.value;
        
        emit Commited(msg.sender, msg.value, this.balance, getCurrentPrice());
    }

    function getCurrentPrice() view public returns (uint256 pricePerAuctionToken) {
        pricePerAuctionToken = (this.balance * 10**auctionToken.decimals()) / (_amountToDistribute * 1e18);
    }

    function finalize() public onlyOwner {
        auctionFinalized = true;
    }


    function claim(uint256 amount) external {
       require(auctionFinalized, "VeriAuction (claim): Auction not finalized yet");

       
    }
}
