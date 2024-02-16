#!/bin/bash

set -e

# Define the path to the Fabric binaries and config
FABRIC_BIN_DIR="$HOME/fabric-samples/bin"
FABRIC_CFG_PATH="$HOME/fabric-samples/config"

# Add Fabric binaries to PATH
export PATH=$FABRIC_BIN_DIR:$PATH

# Set the Fabric config path
export FABRIC_CFG_PATH



invokeChaincode() {
    local org=$1
    local peerAddress=$2
    local tlsRootCertFiles=$3
    local functionName=$4
    local args=$5

    echo "Invoking chaincode on $org..."
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n co2_emission --peerAddresses $peerAddress --tlsRootCertFiles $tlsRootCertFiles -c '{"function":"'"$functionName"'","Args":['"$args"']}'
    echo
}

cd ./test-network

# Set environment variables for Org1
echo "Setting environment variables for Org1..."
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

echo "Testing chaincode from Org1..."


echo "Scenario 1: Register a product"
invokeChaincode "Org1" "localhost:7051" "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" "registerProduct" "\"product1\",\"{\\\"CO2Emission\\\":100}\""


