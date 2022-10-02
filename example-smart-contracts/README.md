# `./kevm`
To get in contact with the developers of the k-framework and kevm, go to the channel on [Riot](https://riot.im/app/#/room/#k:matrix.org).

See the [VeriToken-spec.md](./kevm/VeriToken-spec.md) in `./kevm` for instructions. 

An example output of a **successful** spec can be found in [VeriToken-kevm.result](./kevm/VeriToken-kevm.result). 

An example output of a **failing** spec can be found in [VeriToken-kevm.failing-result](./kevm/VeriToken-kevm.failing-result). In the failing spec the we said that `decimals()` should return 18 (`<output> .ByteArray => #buf(32, 18) </output>`) while actually is should return 6 as described in [VeriToken-spec.md](./kevm/VeriToken-spec.md).

# `./smart-contracts`

## Initialize

```bash
$ cd <path to>/smart-contracts
$ yarn install
$ git submodule update --init --recursive -- lib/forge-std
```

## Using foundry in docker for normal development

Congifurations like solc version and optimize runs can be set in [foundry.toml](./smart-contracts/foundry.toml). More info about this can be found in the [docs](https://book.getfoundry.sh/config/?highlight=foundry.toml#configuring-with-foundrytoml).

```bash
$ docker run --rm -v <path to>/example-smart-contracts:/prj ghcr.io/foundry-rs/foundry:latest "cd /prj/smart-contracts && forge test"
```

## SMTChecker (solc)

[SMTChecker](https://docs.soliditylang.org/en/v0.8.17/smtchecker.html) is a model checker. SMTChecker makes uses of a [Bounded Model Checker](https://docs.soliditylang.org/en/v0.8.17/smtchecker.html#model-checking-engines) (BMC) and a [Constraint Horn Clauses engine](https://docs.soliditylang.org/en/v0.8.17/smtchecker.html#constrained-horn-clauses-chc) (CHC). A good video about [horn clauses](https://www.youtube.com/watch?v=hgw59_HBU2A) The CHC engine (that uses a Horn solver (SPACER, part of z3)) takes the whole contract into account over multiple transactions. It should be notes that the BMC (that uses an SMT solver) in SMTChecker is relatively lightweight as it only checks a function in isolation.

Somewhat outdated, but it shows te difficulties of writing a good checker: https://www.aon.com/cyber-solutions/aon_cyber_labs/exploring-soliditys-model-checker/
https://fv.ethereum.org/2021/01/18/smtchecker-and-synthesis-of-external-functions/

Using the custom Docker image because the [official solc image](https://hub.docker.com/r/ethereum/solc) doesn't include z3 and/or cvc4.

For more information about the SMTChecker see the [Solidity docs](https://docs.soliditylang.org/en/v0.8.17/smtchecker.html).

```bash
$ docker run --rm  -v <path to>/example-smart-contracts:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c "solc --base-path /prj/smart-contracts --include-path /prj/smart-contracts/node_modules --include-path /prj/smart-contracts/lib  --model-checker-engine all --model-checker-solvers all --model-checker-targets all --model-checker-timeout 60000 /prj/smart-contracts/src/VeriStake.sol"
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

Note that for hevm to work we need to comment out the transer fucntion on te IERC20 address.

```solidity
veriToken.transferFrom(msg.sender, address(this), amount); // old
// veriToken.transferFrom(msg.sender, address(this), amount); // new
```

Symbolic execution on storage is [not supported](https://github.com/dapphub/dapptools/tree/master/src/hevm#hevm-symbolic). In a blog post on [fv.ethereum.org](https://fv.ethereum.org/2020/07/28/symbolic-hevm-release/#limitations) it shows that (in 2020) hevm still had its limitations. It should be verified with the git repository which of these limiations are still relevant.

First create the runtime binary:

```bash
$ docker run --rm -v <path to>/example-smart-contracts/smart-contracts:/prj ethereum/solc:0.8.13 --base-path /prj --include-path /prj/node_modules --include-path apps/smart-contracts/lib -o /prj/solc-out --bin-runtime --overwrite /prj/src/VeriStakee.sol
```

Then run hevm. The assertions are described [here](https://docs.soliditylang.org/en/latest/control-structures.html#panic-via-assert-and-error-via-require).

```bash
$ docker run --rm  ghcr.io/enzoevers/hevm:latest /bin/bash -c "hevm symbolic --smttimeout 60000 --assertions '[0x00, 0x01, 0x11, 0x12, 021, 0x22, 0x31, 0x32, 0x41, 0x51]' --code $(< <path to>/example-smart-contracts/smart-contracts/solc-out/PrimalityCheck.bin-runtime) --sig 'stake(uint256, uint256)'"
```

The output will  then look like this:

```bash
checking postcondition...
Assertion violation found.
Calldata:
0x7b0472f0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
stake(115792089237316195423570985008687907853269984665640564039457584007913129639935, 0)
Caller:
0x0000000000000000000000000000000000000000
Callvalue:
0
```

As of now, `hevm` is probably better used as part of the whole dapphub framework where the `prove` prefix for tests will make use of hevm. Then also the cheatcodes (as we know from `forge`) can be  used. 