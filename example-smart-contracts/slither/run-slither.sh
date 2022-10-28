#!/bin/bash

projectRoot=$1
contractName=$2

echo ""
echo "================================================================="
echo "Run Slither"
echo "================================================================="
echo ""

docker run --rm -v ${projectRoot}:/prj ghcr.io/byont-ventures/analysis-tools:latest /bin/bash -c "  \
    cd /prj/slither/                                            \
    && rm -f /prj/slither/${contractName}-output.json           \
    && slither --json /prj/slither/${contractName}-output.json  \
    --config-file /prj/slither/slither.config.json              \
    /prj/smart-contracts/src/${contractName}.sol"