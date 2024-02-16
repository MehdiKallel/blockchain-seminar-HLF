#!/bin/bash

# Exit on first error
set -e

# Check for chaincode directory parameter
if [ -z "$1" ]; then
    echo "Usage: $0 chaincode-javascript"
    exit 1
fi

CHAINCODE_DIR=$1
CHAINCODE_NAME="co2_emission"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

# Function to validate command execution
validateCommand() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}SUCCESS:${NO_COLOR} $1"
    else
        echo -e "${RED}ERROR:${NO_COLOR} $1"
        exit 1
    fi
}

echo "Navigating to the test network directory..."
cd ./test-network

echo "Bringing down any previously set up network..."
./network.sh down

echo "Starting the network and creating a channel..."
./network.sh up createChannel

# Set environment variables for Org1
echo "Setting environment variables for Org1..."
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

echo "Packaging the chaincode..."
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ../${CHAINCODE_DIR}/ --lang node --label ${CHAINCODE_NAME}
validateCommand "Chaincode packaging"

echo "Installing the chaincode on Org1..."
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
validateCommand "Chaincode installation on Org1"

echo "Saving the package ID as a variable..."
CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled | grep "${CHAINCODE_NAME}" | sed -n 's/Package ID: //; s/, Label:.*$//p')
echo "Package ID: $CC_PACKAGE_ID"
validateCommand "Package ID retrieval"

echo "Approving the chaincode for Org1..."
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name ${CHAINCODE_NAME} --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
validateCommand "Chaincode approval on Org1"

# Set environment variables for Org2
echo "Setting environment variables for Org2..."
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

echo "Installing the chaincode on Org2..."
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
validateCommand "Chaincode installation on Org2"

echo "Approving the chaincode for Org2..."
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name ${CHAINCODE_NAME} --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
validateCommand "Chaincode approval on Org2"


echo "Committing the chaincode to the channel..."
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name ${CHAINCODE_NAME} --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
validateCommand "Chaincode commit"

echo "Chaincode has been deployed successfully!"
