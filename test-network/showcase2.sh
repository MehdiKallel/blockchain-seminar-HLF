#!/bin/bash
# Script to demonstrate the CO2 Emission Chaincode

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

# Function to print in color
printInColor() {
    local color=$1
    local message=$2
    tput setaf "$color"
    echo "$message"
    tput sgr0
}

# Function to set environment variables for Org1
setOrg1Env() {
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    echo "Environment set for Org1"
}

# Function to set environment variables for Org2
setOrg2Env() {
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    echo "Environment set for Org2"
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

# Register initial 10 products
registerInitialProducts() {
    for i in {1..10}
    do
        local productId="product$i"
        local emissionData="$((50 + RANDOM % 200))kg CO2"
        printInColor 3 "Registering $productId with emission data $emissionData"
        invokeChaincode "registerProduct" "\"$productId\", \"$emissionData\""
        sleep 2
    done
}

# Initialize the ledger and register 10 products
setOrg1Env
invokeChaincode "initLedger" ""
sleep 5
registerInitialProducts

# Loop to perform operations on the 10 products
while true; do
    for i in {1..10}
    do
        local productId="product$i"

        # Org2: Update Emission Data
        setOrg2Env
        local emissionData="$((50 + RANDOM % 200))kg CO2"
        printInColor 4 "Org2: Updating Emission Data for $productId with $emissionData"
        invokeChaincode "updateEmissionData" "\"$productId\", \"$emissionData\""
        sleep 2

        # Org1: Verify Emissions
        setOrg1Env
        local auditorId="auditor_$i"
        local auditReport="Report_$i"
        printInColor 6 "Org1: Verifying Emissions for $productId"
        invokeChaincode "verifyEmissions" "\"$productId\", \"$auditorId\", \"$auditReport\""
        sleep 2

        # Org2: Issue CO2 Certificate
        setOrg2Env
        local certificateId="cert_$i"
        local emissionAmount="$((1000 + RANDOM % 5000))"
        printInColor 2 "Org2: Issuing CO2 Certificate for $productId"
        invokeChaincode "issueCO2Certificate" "\"$productId\", \"$certificateId\", \"$emissionAmount\""
        sleep 2

        # Org1: Add Consumer Feedback
        setOrg1Env
        local consumerId="consumer_$i"
        local feedback="Great product $i"
        printInColor 5 "Org1: Adding Consumer Feedback for $productId"
        invokeChaincode "consumerFeedback" "\"$productId\", \"$consumerId\", \"$feedback\""
        sleep 2

        # Org2: Query a Product
        setOrg2Env
        printInColor 1 "Org2: Querying $productId"
        invokeChaincode "queryProduct" "\"$productId\""
        sleep 2
    done
done

echo "Demo script execution completed."

