# VeriToken verification

```k
requires "edsl.md"
requires "optimizations.md"
requires "lemmas/lemmas.k"
```

## Solidity code
---
File [VeriToken.sol](../smart-contracts/src/VeriToken.sol) contains the solidity code being verified.

Call the following to generate `VeriToken-bin-runtime.k`.

```bash
$ cd <path to>/smart-contracts
$ yarn install
$ git submodule update --init --recursive -- lib/forge-std

$ docker run --rm -v <path to>/example-smart-contracts:/prj ghcr.io/foundry-rs/foundry:latest "cd /prj/smart-contracts && forge flatten --output ../flattened/VeriToken-flat.sol src/VeriToken.sol"
$ docker run --rm -v <path to>/example-smart-contracts:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c "mkdir -p /prj/kevm/generated && kevm solc-to-k /prj/flattened/VeriToken-flat.sol VeriToken > /prj/kevm/generated/VeriToken-bin-runtime.k"
```

```bash
$ docker run --rm -v <path to>/example-smart-contracts:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c "kevm prove --backend haskell /prj/kevm/VeriToken-spec.md --verif-module VERITOKEN-SPEC"
```

## Verification module
---

```k
requires "generated/VeriToken-bin-runtime.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS
    imports EVM-OPTIMIZATIONS
    imports VERITOKEN-BIN-RUNTIME

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
