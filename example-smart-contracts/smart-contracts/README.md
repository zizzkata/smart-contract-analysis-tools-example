# Using docker

```
cd <path to>/smart-contracts
```

```
git submodule update --init --recursive -- lib/forge-std
```


## Windows
```
docker run -v %cd%:/prj ghcr.io/foundry-rs/foundry:latest "cd /prj && forge test"
```