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
outputFile=$(dirname "$0")/results/${contractName}/${contractName}-Mythril.result

echo ""                                                                     | tee ${outputFile}
echo "================================================================="    | tee -a ${outputFile}
echo "Flatten the contract to be verified"                                  | tee -a ${outputFile}
echo "================================================================="    | tee -a ${outputFile}
echo ""                                                                     | tee -a ${outputFile}

docker run --rm -v ${projectRoot}:/prj ghcr.io/foundry-rs/foundry:latest "  \
    cd /prj                                                                 \
    && forge flatten                                                        \
    --output /prj/security-scans/flattened/${contractName}-flat.sol         \
    ./src/smart-contracts/${contractName}.sol" 2>&1 | tee -a ${outputFile}

echo ""                                                                     | tee -a ${outputFile}
echo "================================================================="    | tee -a ${outputFile}    
echo "Run Mythril"                                                          | tee -a ${outputFile}
echo "================================================================="    | tee -a ${outputFile}
echo ""                                                                     | tee -a ${outputFile}

docker run --rm -v ${projectRoot}:/prj mythril/myth:0.23.10                 \
    -v 4 analyze                                                            \
    --max-depth 50                                                          \
    /prj/security-scans/flattened/${contractName}-flat.sol:${contractName}  \
    2>&1 | tee -a ${outputFile}