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

mkdir -p $(dirname "$0")/results/${contractName}
outputFile=$(dirname "$0")/results/${contractName}/${contractName}-Slither.result

echo ""                                                                     | tee ${outputFile}
echo "================================================================="    | tee -a ${outputFile}
echo "Run Slither"                                                          | tee -a ${outputFile}
echo "================================================================="    | tee -a ${outputFile}        
echo ""                                                                     | tee -a ${outputFile}

docker run --rm -v ${projectRoot}:/prj ghcr.io/byont-ventures/analysis-tools:latest /bin/bash -c "  \
    cd /prj                                                                                         \
    && rm -f ./security-scans/slither/${contractName}-output.json                                   \
    && slither --json ./security-scans/slither/results/${contractName}/${contractName}-output.json  \
    --config-file ./security-scans/slither/slither.config.json                                      \
    ./src/smart-contracts/${contractName}.sol" 2>&1 | tee -a ${outputFile}
