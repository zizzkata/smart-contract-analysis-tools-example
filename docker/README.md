# Docker

## Images

> NOTE: Currently only amd64 / x86-64 compatible images are available.

- hevm: [ghcr.io/byont-ventures/hevm:latest](https://github.com/orgs/Byont-Ventures/packages/container/package/hevm)
- kevm: [ghcr.io/byont-ventures/kevm:latest](https://github.com/orgs/Byont-Ventures/packages/container/package/kevm)

## Build and push images
You might need sudo depending on your system.

To buidl the dockerfile to use `hevm` run:

```bash
$ ./releaseDockerHevm.sh
```

Building the image to use `kevm` requires;

```bash
$ ./releaseDockerKevm.sh
```