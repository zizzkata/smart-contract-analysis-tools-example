# Setup

```bash
$ cd <path to>/smart-contracts
$ yarn install
$ git submodule update --init --recursive -- lib/forge-std
```

# Using foundry in docker for normal development

Congifurations like solc version and optimize runs can be set in [foundry.toml](./smart-contracts/foundry.toml). More info about this can be found in the [docs](https://book.getfoundry.sh/config/?highlight=foundry.toml#configuring-with-foundrytoml).

```bash
$ docker run --rm -v ${PWD}:/prj ghcr.io/foundry-rs/foundry:latest "cd /prj/smart-contracts && forge test -vvv"
```

# Creating contracts with problems

## [VeriAuctionTokenForEth_problems.sol](./smart-contracts/src/VeriAuctionTokenForEth_problems.sol)

> TODO: add more detailed descriptions of the possible attacks.

Some attacks are demonstrated in [VeriAuctionTokenForEth_problems_reentrancy.t.sol](./smart-contracts/test/VeriAuctionTokenForEth_problems_reentrancy.t.sol) which uses [VeriAuctionTokenForEth_reentrancy_attacker.sol](./smart-contracts/test/Attackers/VeriAuctionTokenForEth_reentrancy_attacker.sol) as the attacking contract. The comments in [VeriAuctionTokenForEth_problems.sol](./smart-contracts/src/VeriAuctionTokenForEth_problems.sol) also give some description about the possible exploits.

Currently two attacks are tested to work using the [unit tests](./smart-contracts/test/VeriAuctionTokenForEth_problems_reentrancy.t.sol).

### Getting a large amount of ETH out of the contract
The auction contract allows for users to resign from the auction. This could be a legitimate feature in a auction for certain use cases. However, since ETH is used as the commitment token, this ETH also has to be sent back to the user. The [attacker](./smart-contracts/test/Attackers/VeriAuctionTokenForEth_reentrancy_attacker.sol) can then implement it's fallback function such that the `resignFromAuction()` function is called multiple times. Each time making the auction send the amount of committed ETH back to the attacker.

This is possible due to these lines in [VeriAuctionTokenForEth_problems.sol](./smart-contracts/src/VeriAuctionTokenForEth_problems.sol):

```Solidity
// VeriAuctionTokenForEth_problems.sol

function resignFromAuction() external override {

    ...

    // In these three lines the re-entrancy attack happens.
    (bool transferSuccess, ) = msg.sender.call{value: commitment}("");
    require(transferSuccess, "VeriAuctionTokenForEth (resignFromAuction): failed to send ETH");
        
    delete commited[msg.sender];
}
```

The attacker's code would like like as shown below. Still this attack might fail when there is not enough ETH in the auction contract left. So the attacker could also check first if there is still enough balance to steal.

```Solidity
// VeriAuctionTokenForEth_reentrancy_attacker.sol

fallback () external payable {
    if(timesToAttack > 0) {
        timesToAttack--;
        (bool success, ) = msg.sender.call(abi.encodeWithSelector(IVeriAuctionTokenForEth.resignFromAuction.selector));
        require(success, "Failed to claim ETH");
    }
}
```

An easy fix is the following:

```Solidity
// VeriAuctionTokenForEth_problems.sol

function resignFromAuction() external override {

    ...

    // Prevent re-entrancy attack by setting the commitment to 0 before transferring the ETH.
    delete commited[msg.sender];

    (bool transferSuccess, ) = msg.sender.call{value: commitment}("");
    require(transferSuccess, "VeriAuctionTokenForEth (resignFromAuction): failed to send ETH");
}
```

### Getting both the commitment and the claimable tokens
This attack is similar to the previous attack. The difference however is that now the attacker can only get it's own commited ETH back plus the tokens which would be claimable would the attacker have called `claimTokens()`.

First the attacker has to call the `resignFromAuction()` function as in the previous attack. The attacker now does something different in the fallback function. It simply calls `claimTokens()` as shown below.

```Solidity
// VeriAuctionTokenForEth_reentrancy_attacker.sol

fallback () external payable {
    (bool success, ) = msg.sender.call(abi.encodeWithSelector(IVeriAuctionTokenForEth.claimTokens.selector));
    require(success, "Failed to claim tokens");
}
```

The developer of `claimTokens()` new that it is good to update the local state before calling external functions and thus deleted the commited amount before sending the tokens. However, this didn't prevent the attacker from having already received the commited ETH.

```Solidity
// VeriAuctionTokenForEth_problems.sol

function claimTokens() external override {

    ...

    delete commited[msg.sender];
    auctionToken.transfer(msg.sender, claimableAmount);
}
```

Preventing this attack is excactly the same as for the previous attack.

# Other exploits in the smart contracts

A nice source that explains several exploits and how to prevent them can be seen [here](https://medium.com/hackernoon/hackpedia-16-solidity-hacks-vulnerabilities-their-fixes-and-real-world-examples-f3210eba5148)

Some of these, along with some extra are for example:
- Re-entrancy
    - When sending ETH to a contract address, that address can create custom logic in its fallback function (`function () payable {}`). This logic can then execute anything it wants. It can call the contract that sent the ETH again and try to make it send more ETH.
- Rounding errors
    - A shared savings contract between known people where everyone can take out x% every n days. It can happen that the result results in fewer tokens received than expected due to rounding error. The impact of this depends on how much worth the token is that is withdrawn. 
- Updating storage slots in caller context with `delegatecall()`
    - Overwriting an address
    - Overwriting a value used as the denominator with a huge value, resulting in the division being 0 
- Partly prevent front-running using a check of gas price
    - Front-running is when someone scan the memory pool with incomming transactions (txs), sees a transaction (tx) and copies its calldata by with a higher gas price. This would lead to the miner being more likely to pick the tx with the higher gas price. While not necessarily a vulnerability of a the smart contract, it can be good to keep in mind that this can be partly prevented by checking for a maximum gas price.
- Sending ETH to a contract through selfdestruct of other contact
    - If there would be a pool contract with ETH and an ERC20 token we could make all swaps fail the assert checks for a non-decreasing K value if `this.balance` and an ETH balance counter would be used interchangeably.
    - An auction contract takes ETH and distributes an ERC20 token. Again if `this.balance` and an internal ETH balance counter are used interchangeably, someone can influence this price by sending eth if the price is denominated with `this.balance`.
- Forgetting an access guard on a function
    - Could lead to someone taking ownership of the contract 
- Under/Overflow problems are not a problem anymore with newer Solidity versions.

