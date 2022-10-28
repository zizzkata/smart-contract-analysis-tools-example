#!/bin/bash

projectRoot=$1
contractName=$2
functionSig=$3
solcVersion=$3

echo ""
echo "================================================================="
echo "Generate bin-runtime: solc ${solcVersion}"
echo "================================================================="
echo ""

docker run --rm -v ${projectRoot}s:/prj ethereum/solc:${solcVersion} --base-path /prj --include-path /prj/node_modules --include-path /prj/lib -o /prj/src/smart-contracts/solc-out --bin-runtime --overwrite /prj/src/smart-contracts/${contractName}.sol

echo ""
echo "================================================================="
echo "Function: ${functionSig}"
echo "================================================================="
echo ""

# The assertions options are described [here](https://docs.soliditylang.org/en/latest/control-structures.html#panic-via-assert-and-error-via-require).
docker run --rm ghcr.io/byont-ventures/analysis-tools:latest /bin/bash -c "         \ 
    hevm symbolic --smttimeout 60000                                                \
    --assertions '[0x00, 0x01, 0x11, 0x12, 021, 0x22, 0x31, 0x32, 0x41, 0x51]'      \
    --storage-model InitialS                                                        \
    --code $(< ${projectRoot}/src/smart-contracts/solc-out/${contractName}.bin-runtime) \
    --sig '${functionSig}'"