# Setup

```bash
$ cd <path to>/smart-contracts
$ yarn install
$ git submodule update --init --recursive -- lib/forge-std
```

# Using foundry in docker for normal development

Congifurations like solc version and optimize runs can be set in [foundry.toml](./smart-contracts/foundry.toml). More info about this can be found in the [docs](https://book.getfoundry.sh/config/?highlight=foundry.toml#configuring-with-foundrytoml).

```bash
$ docker run --rm -v ${PWD}:/prj ghcr.io/foundry-rs/foundry:latest "cd /prj/smart-contracts && forge test"
```