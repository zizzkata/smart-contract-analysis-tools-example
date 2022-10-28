#!/bin/bash

projectRoot=$1
contractName=$2

echo ""
echo "================================================================="
echo "Run Slither"
echo "================================================================="
echo ""

cp slither.config.json ${projectRoot}/smart-contracts/slither.config.json

docker run --rm -v ${projectRoot}:/prj ghcr.io/byont-ventures/analysis-tools:latest /bin/bash -c "  \
    cd /prj/smart-contracts &&                              \
    slither --json /prj/slither/${contractName}-output.json \
    --config-file /prj/smart-contracts/slither.config.json  \
    /prj/smart-contracts/src/${contractName}.sol"

rm ${projectRoot}/smart-contracts/slither.config.json
