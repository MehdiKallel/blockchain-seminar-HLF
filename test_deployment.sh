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

# Test Scenarios for Org1
echo "Testing chaincode from Org1..."

# Scenario 1: Register a product
echo "Scenario 1: Register a product"
invokeChaincode "Org1" "localhost:7051" "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" "registerProduct" "\"product1\",\"{\\\"CO2Emission\\\":100}\""

# Scenario 2: Query a product
echo "Scenario 2: Query a product"
invokeChaincode "Org1" "localhost:7051" "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" "queryProduct" "\"product1\""

# Set environment variables for Org2
echo "Setting environment variables for Org2..."
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

# Test Scenarios for Org2
echo "Testing chaincode from Org2..."

# Scenario 3: Update emission data for a product
echo "Scenario 3: Update emission data for a product"
invokeChaincode "Org2" "localhost:9051" "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" "updateEmissionData" "\"product1\",\"{\\\"CO2Emission\\\":150}\""

# Scenario 4: Verify emissions for a product
echo "Scenario 4: Verify emissions for a product"
invokeChaincode "Org2" "localhost:9051" "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" "verifyEmissions" "\"product1\",\"auditor1\",\"Audit Report 1\""

echo "Chaincode testing completed."

