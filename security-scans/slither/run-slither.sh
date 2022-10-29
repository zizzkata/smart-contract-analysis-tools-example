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

cp ${projectRoot}/security-scans/slither/slither.config.json ${projectRoot}/slither.config.json

docker run --rm -v ${projectRoot}:/prj ghcr.io/byont-ventures/analysis-tools:latest /bin/bash -c "  \
    rm -f /prj/security-scans/slither/${contractName}-output.json                                           \
    && slither --json /prj/security-scans/slither/${contractName}-output.json    \
    /prj/src/smart-contracts/${contractName}.sol" 2>&1 | tee -a ${outputFile}

rm ${projectRoot}/slither.config.json