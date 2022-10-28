#!/bin/bash

projectRoot=$1
contractName=$2

echo ""
echo "================================================================="
echo "Running SMTChecker"
echo "================================================================="
echo ""

docker run --pull --rm -v ${projectRoot}:/prj ghcr.io/byont-ventures/analysis-tools:latest bash -c " \
    solc --base-path /prj/smart-contracts               \
    --include-path /prj/smart-contracts/node_modules    \
    --include-path /prj/smart-contracts/lib             \
    --model-checker-engine all                          \
    --model-checker-solvers all                         \
    --model-checker-targets all                         \
    --model-checker-timeout 60000                       \
    /prj/smart-contracts/src/${contractName}.sol"