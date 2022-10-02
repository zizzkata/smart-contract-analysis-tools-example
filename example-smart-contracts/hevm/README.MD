# hevm

Note that for hevm to work we need to comment out the transer fucntion on te IERC20 address.

```solidity
veriToken.transferFrom(msg.sender, address(this), amount); // old
// veriToken.transferFrom(msg.sender, address(this), amount); // new
```

Symbolic execution on storage is [not supported](https://github.com/dapphub/dapptools/tree/master/src/hevm#hevm-symbolic). In a blog post on [fv.ethereum.org](https://fv.ethereum.org/2020/07/28/symbolic-hevm-release/#limitations) it shows that (in 2020) hevm still had its limitations. It should be verified with the git repository which of these limiations are still relevant.

First create the runtime binary:

```bash
$ docker run --rm -v <path to>/example-smart-contracts/smart-contracts:/prj ethereum/solc:0.8.13 --base-path /prj --include-path /prj/node_modules --include-path apps/smart-contracts/lib -o /prj/solc-out --bin-runtime --overwrite /prj/src/VeriStake.sol
```

Then run hevm. The assertions are described [here](https://docs.soliditylang.org/en/latest/control-structures.html#panic-via-assert-and-error-via-require).

```bash
$ docker run --rm  ghcr.io/byont-ventures/hevm:latest /bin/bash -c "hevm symbolic --smttimeout 60000 --assertions '[0x00, 0x01, 0x11, 0x12, 021, 0x22, 0x31, 0x32, 0x41, 0x51]' --storage-model InitialS --code $(< <path to>/example-smart-contracts/smart-contracts/solc-out/VeriStake.bin-runtime) --sig 'stake(uint256, uint256)'"
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
