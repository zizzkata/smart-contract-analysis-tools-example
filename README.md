# Smart contract formal verification

In `example-smart-contracts` you will find an environment where we have a standard forge project (`smart-contracts`). We also have a kevm specification (in `kevm`) in which we describe the specifications for the contracts to formally verify.

Instruction on how to formally verify a smart contract can be found in `./example-smart-contracts/kevm/VeriToken-spec.md`.
Instruction on how to use other formal verification tools like **SMTChecker** and **hevm** can be found in `./example-smart-contracts/README.md`.

To get in contact with the developers of the k-framework and kevm, go to the channel on [Riot](https://riot.im/app/#/room/#k:matrix.org).

## Formal verification

Formal verification is a very wide field. The 'amount' and what kind of formal verification should be done on a project depends per project.

### Satisfiable Modulo Theory (SMT)
In short, SMT allows us to define a set of constraints and determine if it can be true or not (satisfiability).

### Symbolic execution

### Matching logic

## Docker

Installing formal verification tools can take quite some time. Additionally, installing kevm can be a bit tricky since it is still development. Therefore docker images are created to make life easier.

### Note on cpu architecture

Currently there are only `x86_64` compatibal images built.

### hevm
```bash
$ docker build -t ghcr.io/enzoevers/hevm:latest -f Dockerfile.hevm .
$ docker push ghcr.io/enzoevers/hevm:latest
```

### kevm
```bash
$ docker build -t ghcr.io/enzoevers/kevm-solc:latest -f Dockerfile.kevm .
$ docker push ghcr.io/enzoevers/kevm-solc:latest
```
