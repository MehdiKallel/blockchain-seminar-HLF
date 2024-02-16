#!/bin/bash
# Script to demonstrate the CO2 Emission Chaincode


docker stop $(docker ps -aq)

docker rm $(docker ps -aq)

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/


peer version

