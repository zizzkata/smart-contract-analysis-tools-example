#!/bin/bash

projectRoot=$1
contractName=$2

echo ""
echo "================================================================="
echo "Flatten the contract to be verified"
echo "================================================================="
echo ""

docker run --rm -v ${projectRoot}:/prj ghcr.io/foundry-rs/foundry:latest "  \
    cd /prj/smart-contracts                                                 \
    && forge flatten src/${contractName}.sol                                \
    --output ../flattened/${contractName}-flat.sol"

echo ""
echo "================================================================="
echo "Run Slither"
echo "================================================================="
echo ""

# docker run --rm  ghcr.io/byont-ventures/analysis-tools:latest /bin/bash -c "        \
#     slither --json ${projectSlitherOutput}/slither-${nameNoExtention}-${printer}-output.json \
#     --config-file ${projectRoot}/local.json \
#     ${src} 2>&1 | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | tee ${projectSlitherOutput}/slither-${nameNoExtention}-${printer}-output.log
