# VeriToken verification

```k
requires "edsl.md"
requires "optimizations.md"
requires "lemmas/lemmas.k"
```

## Solidity code
---
File [VeriToken.sol](../smart-contracts/src/VeriToken.sol) contains the solidity code being verified.

Setup the local environment.
```bash
$ cd <path to>/example-smart-contracts                        
$ export projectPath=$PWD                                          \
    && export contractName=VeriToken                               \
    && cd ./smart-contracts                                        \
    && yarn install                                                \
    && git submodule update --init --recursive -- lib/forge-std    \
    && cd ../
```

Flatten the contract to be verified.
```bash
$ docker run --rm -v $projectPath:/prj ghcr.io/foundry-rs/foundry:latest "  \
    cd /prj/smart-contracts                                                 \
    && forge flatten src/$contractName.sol                                  \
    --output ../flattened/$contractName-flat.sol"
```

Generate helper modules for kevm to make writing claims easier.
```bash
$ docker run --rm -v $projectPath:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c "                 \
    mkdir -p /prj/kevm/generated                                                                    \
    && kevm solc-to-k /prj/flattened/$contractName-flat.sol $contractName                           \
    --pyk --verbose --profile --verbose --definition root/evm-semantics/.build/usr/lib/kevm/haskell \
    --main-module $contractName-VERIFICATION                                                        \
    > /prj/kevm/generated/$contractName-bin-runtime.k"
```

Generate the required files for verification.
```bash
$ docker run --rm -v $projectPath:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c "                 \
    kevm kompile --backend haskell /prj/kevm/$contractName-spec.md                                  \
        --definition /prj/kevm/generated/$contractName-spec/haskell                                 \
        --main-module VERIFICATION                                                                  \
        --syntax-module VERIFICATION                                                                \
        --concrete-rules-file /root/evm-semantics/tests/specs/examples/concrete-rules.txt           \
        -I root/evm-semantics/.build/usr/lib/kevm/include/kframework                                \
        -I root/evm-semantics/.build/usr/lib/kevm/blockchain-k-plugin/include/kframework            \
        --verbose" 
```

Verify the the Solidity contract
```bash
$ docker run --rm -v $projectPath:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c " \
    kevm prove --backend haskell /prj/kevm/$contractName-spec.md                    \
        --definition /prj/kevm/generated/$contractName-spec/haskell                 \
        --verbose"
```

## Verification module
---

```k
requires "generated/VeriToken-bin-runtime.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS
    imports EVM-OPTIMIZATIONS
    imports VeriToken-VERIFICATION

    syntax Step ::= ByteArray | Int
    syntax KItem ::= runLemma ( Step ) | doneLemma ( Step )
 // -------------------------------------------------------
    rule <k> runLemma(S) => doneLemma(S) ... </k>

 // decimals lemmas
 // ---------------

    rule         255 &Int X <Int 256 => true requires 0 <=Int X [simplification, smt-lemma]
    rule 0 <=Int 255 &Int X          => true requires 0 <=Int X [simplification, smt-lemma]

endmodule
```

## K specification
---

```k
module VERITOKEN-SPEC
    imports VERIFICATION
```

### Functional claims

```k
claim <k> runLemma(#bufStrict(32, #loc(VeriToken._allowances[OWNER]))) => doneLemma(#buf(32, keccak(#buf(32, OWNER) ++ #buf(32, 1)))) ... </k>
      requires #rangeAddress(OWNER)
```

### Calling decimals() works

```k
claim [decimals]:
    <mode>     NORMAL   </mode>
    <schedule> ISTANBUL </schedule>

    <callStack> .List                                      </callStack>
    <program>   #binRuntime(VeriToken)                         </program>
    <jumpDests> #computeValidJumpDests(#binRuntime(VeriToken)) </jumpDests>

    <id>         ACCTID      => ?_ </id>
    <localMem>   .Memory     => ?_ </localMem>
    <memoryUsed> 0           => ?_ </memoryUsed>
    <wordStack>  .WordStack  => ?_ </wordStack>
    <pc>         0           => ?_ </pc>
    <endPC>      _           => ?_ </endPC>
    <gas>        #gas(_VGAS) => ?_ </gas>
    <callValue>  0           => ?_ </callValue>

    <callData>   VeriToken.decimals()                 </callData>
    <k>          #execute   => #halt ...          </k>
    <output>     .ByteArray => #buf(1, 6) </output>
    <statusCode> _          => EVMC_SUCCESS       </statusCode>

    <account>
    <acctID> ACCTID </acctID>
    <storage> ACCT_STORAGE </storage>
        ...
    </account>
```

### Calling totalSupply() works

```k
claim [totalSupply]:
    <mode>     NORMAL   </mode>
    <schedule> ISTANBUL </schedule>

    <callStack> .List                                      </callStack>
    <program>   #binRuntime(VeriToken)                         </program>
    <jumpDests> #computeValidJumpDests(#binRuntime(VeriToken)) </jumpDests>

    <id>         ACCTID      => ?_ </id>
    <localMem>   .Memory     => ?_ </localMem>
    <memoryUsed> 0           => ?_ </memoryUsed>
    <wordStack>  .WordStack  => ?_ </wordStack>
    <pc>         0           => ?_ </pc>
    <endPC>      _           => ?_ </endPC>
    <gas>        #gas(_VGAS) => ?_ </gas>
    <callValue>  0           => ?_ </callValue>

    <callData>   VeriToken.totalSupply()                 </callData>
    <k>          #execute   => #halt ...             </k>
    <output>     .ByteArray => #buf(32, TOTALSUPPLY) </output>
    <statusCode> _          => EVMC_SUCCESS          </statusCode>

    <account>
        <acctID> ACCTID </acctID>
        <storage> ACCT_STORAGE </storage>
        ...
     </account>

    requires TOTALSUPPLY_KEY ==Int #loc(VeriToken._totalSupply)
        andBool TOTALSUPPLY     ==Int #lookup(ACCT_STORAGE,  TOTALSUPPLY_KEY)
```

```k
endmodule
```
