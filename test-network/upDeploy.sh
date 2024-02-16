#!/bin/bash
cd ../explorer
docker-compose down
cd ../test-network
sleep 5
docker volume rm $(docker volume ls -q)
sleep 2
./network down
sleep 3
./network.sh up createChannel
sleep 10
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript -ccl javascript
