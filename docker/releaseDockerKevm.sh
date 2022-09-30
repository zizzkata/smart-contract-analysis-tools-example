#!/bin/bash

echo ""
echo "================================================================="
echo "Build and push Dockerfile.kevm"
echo "================================================================="
echo ""

docker buildx create --use
docker buildx build --push --platform=linux/amd64,linux/arm64 --pull -t ghcr.io/byont-ventures/kevm:local -f Dockerfile.kevm  .