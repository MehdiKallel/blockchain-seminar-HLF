#!/bin/bash
# Script to demonstrate the CO2 Emission Chaincode

export PATH=${PWD}/../bin:$PATH

export FABRIC_CFG_PATH=$PWD/../config/


# Function to set environment variables for Org1
setOrg1Env() {
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

# Function to set environment variables for Org2
setOrg2Env() {
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

# Function to invoke a chaincode method
invokeChaincode() {
    local func=$1
    local args=$2
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
        -C mychannel -n basic \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
        --peerAddresses localhost:9051 \
        --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
        -c "{\"function\":\"$func\",\"Args\":[$args]}"
}

# Initialize the ledger with some assets
setOrg1Env
invokeChaincode "initLedger" ""
sleep 5

# Register a product with Org1
setOrg1Env
productData='"product6", "data6"'
invokeChaincode "registerProduct" "$productData"
sleep 10

# Update emission data for a product with Org2
setOrg2Env
updateData='"product6", "updatedData"'
invokeChaincode "updateEmissionData" "$updateData"
sleep 10

# Verify emissions for a product with Org1
setOrg1Env
verifyData='"product6", "auditor1", "auditReport1"'
invokeChaincode "verifyEmissions" "$verifyData"
sleep 10

# Issue a CO2 certificate with Org2
setOrg2Env
certificateData='"product6", "certificate1", "100"'
invokeChaincode "issueCO2Certificate" "$certificateData"
sleep 10

# Add consumer feedback with Org1
setOrg1Env
feedbackData='"product6", "consumer1", "Great product"'
invokeChaincode "consumerFeedback" "$feedbackData"
sleep 5

# Query a product with Org2
setOrg2Env
invokeChaincode "queryProduct" '"product6"'
sleep 5

echo "Demo script execution completed."

