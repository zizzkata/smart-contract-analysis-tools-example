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
### ERC20 token ([VeriToken](./smart-contracts/src/VeriToken.sol))
One of the most popular smart contract standard is ERC20. The makes sure that we are use imports and that we can call functions from that import.

### Staking contract ([VeriStake](./smart-contracts/src/VeriToken.sol))
This staking contract makes use of our ERC20 token and locks up the token for a certain amount of time.

# `./smart-contracts`
---
## Initialize
```bash

$ cd <path to>/smart-contracts
$ yarn install
$ git submodule update --init --recursive -- lib/forge-std
```

## Using foundry in docker

```bash
$ docker run -v <path to>/example-smart-contracts:/prj ghcr.io/foundry-rs/foundry:latest "cd /prj/smart-contracts && forge test"
```

## SMTChecker (solc)

Using the custom Docker image because the [official solc image](https://hub.docker.com/r/ethereum/solc) doesn't include z3 and/or cvc4.

For more information about the SMTChecker see the [Solidity docs](https://docs.soliditylang.org/en/v0.8.17/smtchecker.html).

```bash
$ docker run -v <path to>/example-smart-contracts:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c "solc --base-path /prj/smart-contracts --include-path /prj/smart-contracts/node_modules --include-path /prj/smart-contracts/lib  --model-checker-engine all --model-checker-solvers all --model-checker-targets all --model-checker-timeout 60000 /prj/smart-contracts/src/VeriStake.sol"
```

The expected output will look like this:

```bash
Warning: CHC: Error trying to invoke SMT solver.
  --> src/VeriStake.sol:50:33:
   |
50 |         uint256 stakedAmount =  staked[msg.sender] + amount;
   |                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^
   
Warning: CHC: Overflow (resulting value larger than 2**256 - 1) happens here.

Counterexample:
veriToken = 0
amount = 0
duration = 2438
stakedAmount = 0
stakedUntil = 0
Transaction trace: 
VeriStake.constructor(0x0) 
State: veriToken = 0
VeriStake.stake(0, 2438){ block.timestamp: 115792089237316195423570985008687907853269984665640564039457584007913129637498, msg.sender: 0x52f6 }
veriToken.transferFrom(msg.sender, address(this), amount) -- untrusted external call
  --> src/VeriStake.sol:51:32:
   |
51 |         uint256 stakedUntil =  block.timestamp + duration;
   |                                ^^^^^^^^^^^^^^^^^^^^^^^^^^
   
Warning: CHC: 1 verification condition(s) could not be proved. Enable the model checker option "show unproved" to see all of them. Consider choosing a specific contract to be verified in order to reduce the solving problems. Consider increasing the timeout per query.

Warning: BMC: Overflow (resulting value larger than 2**256 - 1) happens here.
  --> src/VeriStake.sol:50:33:
   |
50 |         uint256 stakedAmount =  staked[msg.sender] + amount;
   |                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^
Note: Counterexample:
  <result> = 2**256
  amount = 7720
  duration = 0
  stakedAmount = 0
  stakedUntil = 0
  staked[msg.sender] = 0xFFFFffffFFFFffffFFFFffffFFFFffffFFFFffffFFFFffffFFFFffffFFFFe1d8
  this = 0
  veriToken = 0
  
Note: Callstack:
Note:
Note that array aliasing is not supported, therefore all mapping information is erased after a mapping local variable/parameter is assigned.   You can re-introduce information using require().
Note that external function calls are not inlined, even if the source code of the function is available. This is due to the possibility that the actual called contract has the same ABI but implements the function differently.
```

## hevm


# `./kevm`
---
See the [VeriToken-spec.md](./kevm/VeriToken-spec.md) in `./kevm`.
