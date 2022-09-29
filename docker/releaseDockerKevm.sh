#!/bin/bash

echo ""
echo "================================================================="
echo "Build and push Dockerfile.kevm"
echo "================================================================="
echo ""

docker buildx create --use
docker buildx build --platform=linux/amd64,linux/arm64/v8 --pull -t ghcr.io/byont-ventures/kevm:latest -f Dockerfile.kevm  .
docker push ghcr.io/byont-ventures/kevm:latest