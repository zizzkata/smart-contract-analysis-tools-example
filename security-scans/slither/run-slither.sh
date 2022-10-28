#!/bin/bash

projectRoot=$1
contractName=$2

echo ""
echo "================================================================="
echo "Run Slither"
echo "================================================================="
echo ""

docker run --rm -v ${projectRoot}:/prj ghcr.io/byont-ventures/analysis-tools:latest /bin/bash -c "  \
    cd /prj/security-scans/slither/                 \
    && rm -f ${contractName}-output.json            \
    && slither --json ${contractName}-output.json   \
    /prj/src/smart-contracts/${contractName}.sol"