// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20Metadata.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract VeriAuctionTokenForEth is Ownable {

    //========================================
    // Events
    //========================================
    event Commited(address indexed user, uint256 amount, uint256 totalCommited, uint256 newPrice);
    event Claimed(address indexed user, uint256 amount, uint256 price);

    //========================================
    // Variables
    //========================================
    IERC20Metadata public immutable auctionToken;
    uint256 public immutable amountToDistribute;

    // Store this separately to not have to do an external call.
    uint256 private immutable auctionTokenDecimals;

    uint256 finalEthBalance;
    mapping (address => uint256) private commited;

    uint256 unclaimableTokenAmount;

    //========================================
    // constructor
    //========================================

    constructor(address veriTokenAddress, uint256 _amountToDistribute) Ownable() {
        auctionToken = IERC20Metadata(veriTokenAddress);
        auctionTokenDecimals = auctionToken.decimals();
        amountToDistribute = _amountToDistribute;
        finalEthBalance = 0;
        unclaimableTokenAmount = 0;

        // The deployer of this auction contract should have approved the auction
        // contract to transfer the auction token before deploying this contract.
        auctionToken.transferFrom(msg.sender, address(this), _amountToDistribute);
    }

    //========================================
    // functions
    //========================================

    //====================
    // Auction active
    //====================

    /// @notice Commit a certain amount of ETH.
    function commitTokens() payable external {
        require(!auctionFinalized(), "VeriAuctionTokenForEth (commitTokens): Auction is finalized");
        require(msg.value > 0, "VeriAuctionTokenForEth (commitTokens): commitment must be greater than 0");

        commited[msg.sender] += msg.value;
        
        emit Commited(msg.sender, msg.value, this.balance, getCurrentPrice());
    }

    /// @notice The auction is closed and the total amount if ETH is fixed.
    function finalize() public onlyOwner {
        finalBalance = this.balance;
    }
    
    //====================
    // Auction Final
    //====================

    /// @notice Claim an amount of tokens based of the share of a user 
    function claimTokens() external {
        require(auctionFinalized(), "VeriAuctionTokenForEth (claimTokens): Auction not finalized yet");

        uint256 claimableAmount = calculateClaimableAmout();
        
        // These two lines can also be part of the re-entrancy attack in resignFromAuction().
        // Than not only ETH was stolen, but the attacker would also get its share of the auction tokens.
        delete commited[msg.sender];
        auctionToken.transfer(msg.sender, claimableAmount);
    }

    /// @notice Let a user resign from the auction.
    ///         As long as the auction is not finalized this will decrease the price of an auction token.
    ///         When the auction is finalized the price can't change anymore (due to the ETH balance being recorded).
    ///         Instead, when the auction is finalized, the otherwise claimable auction tokens can be withdrawn from
    ///         the contract by the owner of the contract.
    /// @dev User the delete keyword to get some gas back.
    function resignFromAuction() external {
        require(commited[msg.sender] > 0, "VeriAuctionTokenForEth (resignFromAuction): must have commited some ETH");        

        if(auctionFinalized()) {
            // Gas savings
            uint256 _unclaimableTokenAmount = unclaimableTokenAmount;
            
            _unclaimableTokenAmount += calculateClaimableAmout();
            require(_unclaimableTokenAmount <= amountToDistribute, "VeriAuctionTokenForEth (resignFromAuction): unclaimable amount would be larger than total tokens to distribute");
            
            unclaimableTokenAmount = _unclaimableTokenAmount; 
        }

        uint256 commitment = commited[msg.sender];
        require(this.balance >= commitment, "VeriAuctionTokenForEth (resignFromAuction): contract doesn't have enough ETH");

        // In these two lines the re-entrancy attack happens.
        msg.sender.call.value(commitment)();
        delete commited[msg.sender];
    }
    
    /// @notice The owner can claim the tokens that will not be distrubuted due to people resigning.
    /// @dev User the delete keyword to get some gas back.
    function claimUndistributedAuctionTokens() onlyOwner external {
        uint256 tokensToSend = unclaimableTokenAmount;
        delete unclaimableTokenAmount;
        auctionToken.transfer(owner(), tokensToSend);
    }

    //====================
    // Helpers
    //====================

    //==========
    // Public
    //==========

    function auctionFinalized() pure public returns(bool finialized) {
        return finalBalance > 0;
    }

    /// @notice Calculates the price of one whole auction token in eth.
    /// @dev The use of this.balance make for a possible exploit that can increase the
    ///      price of an auction token.
    function getCurrentPrice() view public returns (uint256 pricePerAuctionToken) {
        pricePerAuctionToken = (this.balance * 10**auctionTokenDecimals) / _amountToDistribute;
    }
    
    /// @notice Calculate the amount of tokens can be claimed based on the ETH balance in when the auction
    ///         was closed.
    function calculateClaimableAmout() view public returns (uint256 claimableAmount) {
        require(auctionFinalized(), "VeriAuctionTokenForEth (calculateClaimableAmout): Auction not finalized yet");

        uint256 share = (commited[msg.sender] * 1e18) / finalBalance;
        claimableAmount = (share * _amountToDistribute) / 1e18;
    }
}
