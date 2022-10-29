#!/bin/bash

projectRoot=$1
contractName=$2

if [ -z "$contractName" ]
then
    echo ""
    echo "Please provide the name of the contract without '.sol'"
    echo ""
    exit 1
fi

outputFile=$(dirname "$0")/${contractName}-SMTChecker.result

echo ""                                                                     | tee ${outputFile}
echo "================================================================="    | tee -a ${outputFile}
echo "Running SMTChecker"                                                   | tee -a ${outputFile}
echo "================================================================="    | tee -a ${outputFile}
echo ""                                                                     | tee -a ${outputFile}

docker run --pull --rm -v ${projectRoot}:/prj ghcr.io/byont-ventures/analysis-tools:latest bash -c " \
    cd /prj                                             \
    && solc                                             \
    ds-test/=libs/ds-test/src/                          \
    forge-std/=libs/forge-std/src/                      \
    @openzeppelin/=node_modules/@openzeppelin/          \
    @smart-contracts=src/smart-contracts/               \
    --model-checker-engine all                          \
    --model-checker-solvers all                         \
    --model-checker-targets all                         \
    --model-checker-timeout 60000                       \
    /prj/src/smart-contracts/${contractName}.sol" 2>&1 | tee -a ${outputFile}
