# Context
In order to see how the K framework can work in real world scenarios we need a real work scenario. It should be simple enough however to make it easy to debug

# Scenarios
We would like to have the following scenarios:
0. We should be able to use imports
1. Throw an error which only occures by a sequence of transactions.
2. Make sure that a certain function is always called after another function is called.
3. Make sure that we can define contstraints on variables (non-decreasing, always less than x, etc.).
4. Having an external contract influence another contract.
5. Make sure that a function updates the state of the contract 'as expected'.

Point 4 makes our example have at least 2 contracts.

## Contracts
### ERC20 token
One of the most popular smart contract standard is ERC20. The makes sure that we are use imports and that we can call functions from that import.

### Staking contract
This staking contract makes use of our ERC20 token and locks up the token for a certain amount of time.