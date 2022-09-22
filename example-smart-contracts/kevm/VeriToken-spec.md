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
$ cd <path to repo root>
$ git submodule update --init --recursive -- verified-smart-contracts

$ cd <path to>/smart-contracts
$ yarn install
$ git submodule update --init --recursive -- lib/forge-std

$ docker run -v <path to>/example-smart-contracts:/prj ghcr.io/foundry-rs/foundry:latest "cd /prj/smart-contracts && forge flatten --output ../flattened/VeriToken-flat.sol src/VeriToken.sol"
$ docker run -v <path to>/example-smart-contracts:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c "kevm solc-to-k /prj/flattened/VeriToken-flat.sol VeriToken > /prj/kevm/VeriToken-bin-runtime.k"
```

```bash
$ docker run -v <path to>/example-smart-contracts:/prj ghcr.io/enzoevers/kevm-solc:latest bash -c "kevm kompile /prj/kevm/VeriToken-spec.md --main-module VERITOKEN-SPEC"
```

## Verification module
---

```k
requires "VeriToken-bin-runtime.k"

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
claim <k> runLemma(#bufStrict(32, #loc(ERC20._allowances[OWNER]))) => doneLemma(#buf(32, keccak(#buf(32, OWNER) ++ #buf(32, 1)))) ... </k>
      requires #rangeAddress(OWNER)
```

### Calling decimals() works

```k
claim [decimals]:
    <mode>     NORMAL   </mode>
    <schedule> ISTANBUL </schedule>

    <callStack> .List                                      </callStack>
    <program>   #binRuntime(ERC20)                         </program>
    <jumpDests> #computeValidJumpDests(#binRuntime(ERC20)) </jumpDests>

    <id>         ACCTID      => ?_ </id>
    <localMem>   .Memory     => ?_ </localMem>
    <memoryUsed> 0           => ?_ </memoryUsed>
    <wordStack>  .WordStack  => ?_ </wordStack>
    <pc>         0           => ?_ </pc>
    <endPC>      _           => ?_ </endPC>
    <gas>        #gas(_VGAS) => ?_ </gas>
    <callValue>  0           => ?_ </callValue>

    <callData>   ERC20.decimals()                 </callData>
    <k>          #execute   => #halt ...          </k>
    <output>     .ByteArray => #buf(32, DECIMALS) </output>
    <statusCode> _          => EVMC_SUCCESS       </statusCode>

    <account>
    <acctID> ACCTID </acctID>
    <storage> ACCT_STORAGE </storage>
        ...
    </account>

    requires DECIMALS_KEY ==Int #loc(ERC20._decimals)
        andBool DECIMALS     ==Int 255 &Int #lookup(ACCT_STORAGE, DECIMALS_KEY)
```

```k
endmodule
```
