# CO2 Emission Tracking System on Hyperledger Fabric

This project implements a CO2 emission tracking system using Hyperledger Fabric. It allows organizations to register products, update and verify emission data, issue CO2 certificates, and collect consumer feedback on the blockchain, ensuring data integrity and transparency.

## Prerequisites

Before you begin, ensure you have the following installed:
- Hyperledger Fabric and its prerequisites
- Node.js and npm (for the chaincode written in JavaScript)
- Docker and Docker Compose

## Getting Started

To get the network up and running, and to deploy the chaincode, follow the steps below.

### 1. Start the Network

The `prepare_network_updated.sh` script brings up the Fabric network, creates a channel, and joins the peers to the channel. Run the following command in your terminal:

```bash
bash prepare_network_updated.sh
```


This script performs the following actions:

- Navigates to the test network directory.
- Brings down any previously set up network.
- Starts the network and creates a channel.
- Sets environment variables for Org1 and Org2.
- Packages, installs, and approves the chaincode.
- Commits the chaincode to the channel.


### 2. Test Chaincode Deployment

After deploying the chaincode, use the test_deployment.sh script to test the chaincode functions. This script registers a product and performs various operations to demonstrate the chaincode's capabilities. Run:

```bash
bash test_deployment.sh
```

The chaincode includes several functions (please extend the bash script to test the other functions other than registerProduct):

- initLedger: Initializes the ledger with predefined data.
- registerProduct: Registers a new product with its initial CO2 emission data.
- updateEmissionData: Updates the emission data for a product.
- verifyEmissions: Marks the product's emissions as verified and records the audit report.
- issueCO2Certificate: Issues a CO2 certificate for a product.
- queryProduct: Retrieves details of a product.
- consumerFeedback: Records consumer feedback for a product.

