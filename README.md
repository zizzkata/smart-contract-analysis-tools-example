# Smart contract formal verification

In `example-smart-contracts` you will find an environment where we have a standard forge project (`smart-contracts`). We also have a kevm specification (in `kevm`) in which we describe the specifications for the contracts to formally verify.

Instruction on how to formally verify a smart contract can be found in `./example-smart-contracts/kevm/VeriToken-spec.md`.
Instruction on how to use other formal verification tools like **SMTChecker** and **hevm** can be found in `./example-smart-contracts/README.md`.

To get in contact with the developers of the k-framework and kevm, go to the channel on [Riot](https://riot.im/app/#/room/#k:matrix.org).

## Formal verification

> Note that formal verification itself can only help you understand the difference between what you did (the specification) and how you did it (the actual implementation). You still need to check whether the specification is what you wanted and that you did not miss any unintended effects of it.
>
> https://docs.soliditylang.org/en/v0.8.17/smtchecker.html

Formal verification is a very wide field. The 'amount' and what kind of formal verification should be done on a project depends per project.

Some nice resources about formal verification:
- [Ethereum Formal Verification Blog](https://fv.ethereum.org/)
- [Formal Systems Labratory](https://fsl.cs.illinois.edu/)
- [A list of formal verification tools for ethereum](https://github.com/leonardoalt/ethereum_formal_verification_overview)

### Satisfiable Modulo Theory (SMT)
In short, SMT allows us to define a set of constraints and determine if it can be true or not (satisfiability). The SMT solver which is used in most formal verification tools for the EVM is [z3](https://github.com/Z3Prover/z3).

SMT is used by almost all verification tools.

### Symbolic execution
Symbolic execution takes multiple paths in the code. But instead of using concrete values, symbolic values are used. So when an input variable (after some manipulation) would be used in a branch, the program would take both branches. When one of the branches would then throw as error, the tool would determine a concrete value which would cause the taking of this branch.

The second speaker of [this talk](https://youtu.be/RunMhlTtdKw?t=2033) explain the basics of how it is done in hevm.
An overview of symbolic execution in general with an example can be found [here](https://www.youtube.com/watch?v=wOO5jpoFIss).

### Model checking
Model checking works on the state machine of a system.

An example of a symbolic model checker is [NuSMV](https://nusmv.fbk.eu/). In NuSMV a user will define  all the possible conditional transitions. Usaully this would be generated with a custom script when possible since a complete system can be quite large/complex. Then the user will define the specifications to check for using temporal logic. Whenever NuSMV find a trace (a sequence of transitions) that violates this specification it will print the trace.

https://arieg.bitbucket.io/pdf/satsmtar-school-2018.pdf

### Matching logic
http://www.matching-logic.org/
https://www.youtube.com/watch?v=Awsv0BlJgbo

Matching logic can define a multitude of other logics.

Matching logic lets someone define a language's semantics as rewrite rules.

In matching logic a 'state' in a program is represented as a configuration. A rewrite rule `lhs => rhs` means that when the `lhs` matches the current configuration, it will be rewritten to the `rhs`.

## Verifying code vs bytecode
Here only tools uses in the repo are considered.

Works on Solidity code:
- SMTChecker

Working on bytecode:
- hevm
- kevm

The main benefit of working with bytecode is that you are working with the code which will actually be deployed. You are not dependent of potential error in the compiler.

## Docker

Installing formal verification tools can take quite some time. Additionally, installing kevm can be a bit tricky since it is still development. Therefore docker images are created to make life easier.

### Note on cpu architecture

Currently there are only `x86_64` compatibal images built.

### hevm
```bash
$ docker build -t ghcr.io/enzoevers/hevm:latest -f docker/Dockerfile.hevm .
$ docker push ghcr.io/enzoevers/hevm:latest
```

### kevm
```bash
$ docker build -t ghcr.io/enzoevers/kevm-solc:latest -f docker/Dockerfile.kevm .
$ docker push ghcr.io/enzoevers/kevm-solc:latest
```
