# hevm

Note that for hevm to work we need to comment out the transer fucntion on te IERC20 address.

```solidity
veriToken.transferFrom(msg.sender, address(this), amount); // old
// veriToken.transferFrom(msg.sender, address(this), amount); // new
```

Symbolic execution on storage is [not supported](https://github.com/dapphub/dapptools/tree/master/src/hevm#hevm-symbolic). In a blog post on [fv.ethereum.org](https://fv.ethereum.org/2020/07/28/symbolic-hevm-release/#limitations) it shows that (in 2020) hevm still had its limitations. It should be verified with the git repository which of these limiations are still relevant.

You might need to run `sudo` on the command below.

```bash
$ ./run-hevm-VeriStake.sh 2>&1 | tee VeriStake-hevm.result
```

The output can then be found in [VeriStake-hevm.result](./VeriStake-hevm.result)

As of now, `hevm` is probably better used as part of the whole dapphub framework where the `prove` prefix for tests will make use of hevm. Then also the cheatcodes (as we know from `forge`) can be  used. 
