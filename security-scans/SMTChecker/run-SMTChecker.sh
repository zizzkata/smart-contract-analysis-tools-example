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

echo ""
echo "================================================================="
echo "Running SMTChecker"
echo "================================================================="
echo ""

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
    /prj/src/smart-contracts/${contractName}.sol"