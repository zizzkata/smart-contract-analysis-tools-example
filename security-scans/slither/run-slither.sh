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

outputFile=$(dirname "$0")/${contractName}-Slither.result

echo ""                                                                     | tee ${outputFile}
echo "================================================================="    | tee -a ${outputFile}
echo "Run Slither"                                                          | tee -a ${outputFile}
echo "================================================================="    | tee -a ${outputFile}        
echo ""                                                                     | tee -a ${outputFile}

docker run --rm -v ${projectRoot}:/prj ghcr.io/byont-ventures/analysis-tools:latest /bin/bash -c "  \
    cd /prj/security-scans/slither/                 \
    && rm -f ${contractName}-output.json            \
    && slither --json ${contractName}-output.json   \
    /prj/src/smart-contracts/${contractName}.sol" 2>&1 | tee -a ${outputFile}