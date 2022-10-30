# Smart contract formal verification

## Context

In order to see how the formal verification (FV) tools can work in real world scenarios, we need a real world scenario. It should be simple enough however to make it easy to debug and analyze manually.

## Usage

```bash
$ yarn install
```

```bash
$ git submodule update --init --recursive
```

```bash
$ sudo yarn run sc:test
```

```bash
$ sudo yarn run sc:slither VeriToken
```

## Scenarios

We would like to have the following scenarios: 0. We should be able to use imports

1. Throw an error which only occurs by a sequence of transactions.
2. Make sure that a certain function is always called after another function is called.
3. Make sure that we can define constraints on variables (non-decreasing, always less than x, etc.).
4. Having an external contract influence another contract.
5. Make sure that a function updates the state of the contract 'as expected'.

Point 4 makes our example have at least 2 contracts.

### Contracts

#### ERC20 token ([VeriToken](./example-smart-contracts/smart-contracts/src/VeriToken.sol))

One of the most used smart contract standard is ERC20. The makes sure that we are use imports and that we can call functions from that import.

#### Aucion contract ([VeriAuctionTokenForEth_problems](./example-smart-contracts/smart-contracts/src/VeriAuctionTokenForEth_problems.sol))

An auction contract where some problems are introduced.

## How to use this repository

No custom installation, besides [Docker](https://docs.docker.com/get-docker/), is needed to use this repository. All required tools are already installed in Docker images.

Only solhint should be installed locally with

```bash
$ npm install -g solhint
```

Configuring git to use the githooks folder run

```bash
$ git config core.hooksPath githooks
```

In `./example-smart-contracts/` you will find:

- `*/smart-contracts/`: a standard forge project.
- `*/kevm/`: a kevm specification in which we describe the specifications for the contracts to formally verify with the k-framework.
- `*/hevm/`: files needed to run hevm on the source code.
- `*/SMTChecker/`: files needed to run SMTChecker on the source code.

## Docker

Installing formal verification tools can take quite some time. Additionally, installing kevm can be a bit tricky since it is still development. Therefore docker images are created to make life easier.

See the `./docker/` folder for more info.

## Formal verification

> Note that formal verification itself can only help you understand the difference between what you did (the specification) and how you did it (the actual implementation). You still need to check whether the specification is what you wanted and that you did not miss any unintended effects of it.
>
> https://docs.soliditylang.org/en/v0.8.17/smtchecker.html

Formal verification is a very wide field. The 'amount' and what kind of formal verification should be done on a project depends per project.

Some nice resources about formal verification:

- [Ethereum Formal Verification Blog](https://fv.ethereum.org/)
- [Formal Systems Laboratory](https://fsl.cs.illinois.edu/)
- [A list of formal verification tools for ethereum](https://github.com/leonardoalt/ethereum_formal_verification_overview)

### Satisfiable Modulo Theory (SMT)

In short, SMT allows us to define a set of constraints and determine if it can be true or not (satisfiability). The SMT solver which is used in most formal verification tools for the EVM is [z3](https://github.com/Z3Prover/z3). Note that z3 is more than only a SMT solver (see the [manual](https://microsoft.github.io/z3guide/)).

SMT is used by almost all verification tools.

### Symbolic execution

Symbolic execution takes multiple paths in the code. But instead of using concrete values, symbolic values are used. So when an input variable (after some manipulation) would be used in a branch, the program would take both branches. When one of the branches would then throw as error, the tool would determine a concrete value which would cause the taking of this branch.

This [slideset](https://www-verimag.imag.fr/~mounier/Enseignement/Software_Security/ConcolicExecution.pdf#page=32) has an example of sumbolic execution.
The second speaker of [this talk](https://youtu.be/RunMhlTtdKw?t=2033) explain the basics of how it is done in hevm.
An overview of symbolic execution in general with an example can be found [here](https://www.youtube.com/watch?v=wOO5jpoFIss).

### Model checking

Model checking works on the state machine of a system.

An example of a symbolic model checker is [NuSMV](https://nusmv.fbk.eu/). In NuSMV a user will define all the possible conditional transitions. Usually this would be generated with a custom script when possible since a complete system can be quite large/complex. Then the user will define the specifications to check for using temporal logic. Whenever NuSMV find a trace (a sequence of transitions) that violates this specification it will print the trace.

The tool [SPACER](https://arieg.bitbucket.io/pdf/synasc2019.pdfß) enables model checking in z3 using horn clauses.

### Matching logic

http://www.matching-logic.org/
https://www.youtube.com/watch?v=Awsv0BlJgbo

Matching logic can define a multitude of other logics.

Matching logic lets someone define a language's semantics as rewrite rules.

In matching logic a 'state' in a program is represented as a configuration. A rewrite rule `lhs => rhs` means that when the `lhs` matches the current configuration, it will be rewritten to the `rhs`.

## Verifying source code vs bytecode

Here only tools uses in the repo are considered.

Works on Solidity code:

- SMTChecker

Working on bytecode:

- hevm
- kevm

The main benefit of working with bytecode is that you are working with the code which will actually be deployed. You are not dependent of potential error in the compiler.
