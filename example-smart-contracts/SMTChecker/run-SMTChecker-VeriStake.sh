#!/bin/bash

echo ""
echo "================================================================="
echo "Running SMTChecker"
echo "================================================================="
echo ""

docker run --rm  -v ${PWD}/../:/prj ghcr.io/byont-ventures/kevm:latest bash -c "solc --base-path /prj/smart-contracts --include-path /prj/smart-contracts/node_modules --include-path /prj/smart-contracts/lib  --model-checker-engine all --model-checker-solvers all --model-checker-targets all --model-checker-timeout 60000 /prj/smart-contracts/src/VeriStake.sol"