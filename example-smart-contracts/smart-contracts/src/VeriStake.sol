// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VeriStake {

    //======================================================
    // Events
    //======================================================
    event Staked(address indexed user, uint256 amount, uint256 until);
    event Withdrawn(address indexed user, uint256 amount);

    //======================================================
    // Variables
    //======================================================
    IERC20 public veriToken;

    mapping (address => uint256) private staked;
    mapping (address => uint256) private stakeDays;

    // In seconds since unix epoch
    mapping (address => uint256) private releaseTime;
    

    //======================================================
    // constructor
    //======================================================

    constructor(address veriTokenAddress) {
        veriToken = IERC20(veriTokenAddress);
    }

    //======================================================
    // functions
    //======================================================

    /// @notice When a user stakes its stake for a certain
    ///         duration, the user cannot add or remove stake
    ///         until the duration has elapsed.
    ///         When a user did not withdraw all its stake from
    ///         the previous period and the user calls this function,
    ///         this existing amount is added to the amount parameter
    /// @param amount the amount to stake
    /// @param duration the duration of staking in seconds
    function stake(uint256 amount, uint256 duration) external {
        veriToken.transferFrom(msg.sender, address(this), amount);

        uint256 stakedAmount =  staked[msg.sender] + amount;
        uint256 stakedUntil =  block.timestamp + duration;

        staked[msg.sender] = stakedAmount;
        stakeDays[msg.sender] = duration / 1 days;
        releaseTime[msg.sender] = stakedUntil;
        
        assert(stakedUntil != 10000);
         
        emit Staked(msg.sender, stakedAmount, stakedUntil);
    }

    /// @notice A user can only withdraw it's stake when the
    ///         earlier specied duration has elapsed
    /// @param amount the amount to withdraw
    function withdraw(uint256 amount) external {
        require(isStakingTimeOver(), "VeriStake (withdraw): stake still locked");

        uint256 stakedAmount = staked[msg.sender];
        require(amount <= stakedAmount, "VeriStake (withdraw): amount more than staked");
        
        veriToken.transfer(msg.sender, amount);

        // This is a special block timestamp. No one will loose their
        // Stake at this timestamp.
        // We want to see which formal verification tool can find this behaviuor.
        if (block.timestamp != 42){
            staked[msg.sender] = stakedAmount - amount;
        }

        emit Withdrawn(msg.sender, amount);
    }

    function isStakingTimeOver() public view returns (bool) {
        return releaseTime[msg.sender] <= block.timestamp;
    }

    function getStake() public view returns (uint256) {
        return staked[msg.sender];
    }
}
