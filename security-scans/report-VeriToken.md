# Code report

## Slither


Compiled with solc
Number of lines: 548 (+ 0 in dependencies, + 0 in tests)
Number of assembly lines: 0
Number of contracts: 6 (+ 0 in dependencies, + 0 tests) 

Number of optimization issues: 0
Number of informational issues: 3
Number of low issues: 0
Number of medium issues: 0
Number of high issues: 0

ERCs: ERC20

### check: solc-version

Impact: Informational
Confidence: High

Description: solc-0.8.17 is not recommended for deployment


### check: solc-version

Impact: Informational
Confidence: High

Description: Pragma version[^0.8.13](src/smart-contracts/interfaces/IVeriToken.sol#L2) allows old versions


### check: solc-version

Impact: Informational
Confidence: High

Description: Pragma version[^0.8.13](src/smart-contracts/VeriToken.sol#L2) allows old versions

