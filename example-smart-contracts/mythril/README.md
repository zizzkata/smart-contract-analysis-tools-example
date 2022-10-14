```
docker run --rm -v ${PWD}:/prj mythril/myth:0.23.10 -v 5 analyze /prj/example-smart-contracts/flattened/VeriStake-flat.sol:VeriStake 2>&1 | tee ./example-smart-contracts/mythril/VeriStake-mythril.result
```