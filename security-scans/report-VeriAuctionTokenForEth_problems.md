# Code report

## Slither



Compiled with solc

Number of lines: 474 (+ 0 in dependencies, + 0 in tests)

Number of assembly lines: 0

Number of contracts: 6 (+ 0 in dependencies, + 0 tests) 



Number of optimization issues: 0

Number of informational issues: 5

Number of low issues: 1

Number of medium issues: 1

Number of high issues: 4

ERCs: ERC20



### check: solc-version

- Impact: Informational
- Confidence: High


```Solidity
2 pragma solidity ^0.8.13;
```

### check: solc-version

- Impact: Informational
- Confidence: High


### check: solc-version

- Impact: Informational
- Confidence: High


```Solidity
2 pragma solidity ^0.8.13;
```

### check: low-level-calls

- Impact: Informational
- Confidence: High


**In Function**

```Solidity
96     function resignFromAuction() external override {
97         require(commited[msg.sender] > 0, "VeriAuctionTokenForEth (resignFromAuction): must have commited some ETH");
98 
99         if (auctionFinalized()) {
100             // Gas savings
101             uint256 _unclaimableTokenAmount = unclaimableTokenAmount;
102             _unclaimableTokenAmount += calculateClaimableAmount();
103             require(
104                 _unclaimableTokenAmount <= amountToDistribute,
105                 "VeriAuctionTokenForEth (resignFromAuction): unclaimable amount would be larger than total tokens to distribute"
106             );
107             unclaimableTokenAmount = _unclaimableTokenAmount;
108         }
109 
110         uint256 commitment = commited[msg.sender];
111         require(
112             getEthBalance() >= commitment,
113             "VeriAuctionTokenForEth (resignFromAuction): contract doesn't have enough ETH"
114         );
115 
116         // In these three lines the re-entrancy attack happens.
117         (bool transferSuccess, ) = msg.sender.call{value: commitment}("");
118         require(transferSuccess, "VeriAuctionTokenForEth (resignFromAuction): failed to send ETH");
119 
120         delete commited[msg.sender];
121     }
```

**Lines of relevance**

```Solidity
117         (bool transferSuccess, ) = msg.sender.call{value: commitment}("");
```

### check: naming-convention

- Impact: Informational
- Confidence: High


### check: reentrancy-benign

- Impact: Low
- Confidence: Medium


**In Function**

```Solidity
57     function depositAuctionTokens() external onlyOwner {
58         // The deployer of this auction contract should have approved the auction
59         // contract to transfer the auction token before deploying this contract.
60         auctionToken.transferFrom(msg.sender, address(this), amountToDistribute);
61         auctionStarted = true;
62     }
```

**Lines of relevance**

```Solidity
60         auctionToken.transferFrom(msg.sender, address(this), amountToDistribute);
```

**Lines of relevance**

```Solidity
60         auctionToken.transferFrom(msg.sender, address(this), amountToDistribute);
```

**Lines of relevance**

```Solidity
61         auctionStarted = true;
```

### check: divide-before-multiply

- Impact: Medium
- Confidence: Medium


**In Function**

```Solidity
196     function calculateClaimableAmount() public view returns (uint256 claimableAmount) {
197         require(auctionFinalized(), "VeriAuctionTokenForEth (calculateClaimableAmount): auction not finalized yet");
198 
199         // Note that if we would have used getCurrentPrice() in the contract, then someone
200         // could send eth to the contract using the selfdestruct method and make it so that
201         // no one can claim tokens due to getCurrentPrice() reverting.
202         // Even though a lot of ETH should be sent to the contract, theoratically it is possible.
203         //
204         //  Example:
205         // claimableAmount = (commited[msg.sender] * 10**auctionTokenDecimals) / getCurrentPrice();
206 
207         // We know that share will always be <= 1e18
208         // The constructor already takes care of preventing an overflow in (share * amountToDistribute)
209         uint256 share = (commited[msg.sender] * 1e18) / finalEthBalance;
210         claimableAmount = (share * amountToDistribute) / 1e18;
211     }
```

**Lines of relevance**

```Solidity
209         uint256 share = (commited[msg.sender] * 1e18) / finalEthBalance;
```

**Lines of relevance**

```Solidity
210         claimableAmount = (share * amountToDistribute) / 1e18;
```

### check: reentrancy-eth

- Impact: High
- Confidence: Medium


**In Function**

```Solidity
96     function resignFromAuction() external override {
97         require(commited[msg.sender] > 0, "VeriAuctionTokenForEth (resignFromAuction): must have commited some ETH");
98 
99         if (auctionFinalized()) {
100             // Gas savings
101             uint256 _unclaimableTokenAmount = unclaimableTokenAmount;
102             _unclaimableTokenAmount += calculateClaimableAmount();
103             require(
104                 _unclaimableTokenAmount <= amountToDistribute,
105                 "VeriAuctionTokenForEth (resignFromAuction): unclaimable amount would be larger than total tokens to distribute"
106             );
107             unclaimableTokenAmount = _unclaimableTokenAmount;
108         }
109 
110         uint256 commitment = commited[msg.sender];
111         require(
112             getEthBalance() >= commitment,
113             "VeriAuctionTokenForEth (resignFromAuction): contract doesn't have enough ETH"
114         );
115 
116         // In these three lines the re-entrancy attack happens.
117         (bool transferSuccess, ) = msg.sender.call{value: commitment}("");
118         require(transferSuccess, "VeriAuctionTokenForEth (resignFromAuction): failed to send ETH");
119 
120         delete commited[msg.sender];
121     }
```

**Lines of relevance**

```Solidity
117         (bool transferSuccess, ) = msg.sender.call{value: commitment}("");
```

**Lines of relevance**

```Solidity
120         delete commited[msg.sender];
```

### check: unchecked-transfer

- Impact: High
- Confidence: Medium


**In Function**

```Solidity
138     function claimTokens() external override {
139         require(auctionFinalized(), "VeriAuctionTokenForEth (claimTokens): Auction not finalized yet");
140 
141         uint256 claimableAmount = calculateClaimableAmount();
142 
143         // The writer of this functino might think that using the delete before the transfer prevents
144         // a re-entrancy attack. It actually succeedes in doing that. But it can still be part of another
145         // attack.
146         // These two lines can also be part of the re-entrancy attack in resignFromAuction().
147         // Than not only ETH was stolen, but the attacker would also get its share of the auction tokens.
148         delete commited[msg.sender];
149         auctionToken.transfer(msg.sender, claimableAmount);
150     }
```

**Lines of relevance**

```Solidity
149         auctionToken.transfer(msg.sender, claimableAmount);
```

### check: unchecked-transfer

- Impact: High
- Confidence: Medium


**In Function**

```Solidity
57     function depositAuctionTokens() external onlyOwner {
58         // The deployer of this auction contract should have approved the auction
59         // contract to transfer the auction token before deploying this contract.
60         auctionToken.transferFrom(msg.sender, address(this), amountToDistribute);
61         auctionStarted = true;
62     }
```

**Lines of relevance**

```Solidity
60         auctionToken.transferFrom(msg.sender, address(this), amountToDistribute);
```

### check: unchecked-transfer

- Impact: High
- Confidence: Medium


**In Function**

```Solidity
154     function claimUndistributedAuctionTokens() external onlyOwner {
155         uint256 tokensToSend = unclaimableTokenAmount;
156         delete unclaimableTokenAmount;
157 
158         // The transfer will fail on insufficient balance
159         auctionToken.transfer(owner(), tokensToSend);
160     }
```

**Lines of relevance**

```Solidity
159         auctionToken.transfer(owner(), tokensToSend);
```
