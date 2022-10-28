#!/bin/bash

projectRoot=$1
contractName=$2

echo ""
echo "================================================================="
echo "Flatten the contract to be verified"
echo "================================================================="
echo ""

docker run --rm -v ${projectRoot}:/prj ghcr.io/foundry-rs/foundry:latest "  \
    cd /prj/src/smart-contracts                                             \
    && forge flatten ${contractName}.sol                                    \
    --output /prj/security-scans/flattened/${contractName}-flat.sol"

echo ""
echo "================================================================="
echo "Run Mythril"
echo "================================================================="
echo ""

docker run --rm -v ${projectRoot}:/prj mythril/myth:0.23.10 -v 4 analyze --max-depth 50 /prj/security-scans/flattened/${contractName}-flat.sol:${contractName}