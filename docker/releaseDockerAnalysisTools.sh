#!/bin/bash

echo ""
echo "================================================================="
echo "Build and push Dockerfile.hevm"
echo "================================================================="
echo ""

docker buildx create --use
docker buildx build --push --platform=linux/amd64 --pull -t ghcr.io/byont-ventures/analysis-tools:latest -f Dockerfile.analysisTools  .
