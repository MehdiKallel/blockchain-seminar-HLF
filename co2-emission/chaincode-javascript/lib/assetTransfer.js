const { Contract } = require('fabric-contract-api');

class AssetTransfer extends Contract {

    async initLedger(ctx) {
        console.info('CO2 Emission Ledger Initialized');
        
        const initData = [
            { productId: "product1", initialEmissionData: "150kg CO2" },
            { productId: "product2", initialEmissionData: "200kg CO2" },
            { productId: "product3", initialEmissionData: "300kg CO2" },
        ];
    
        for (const data of initData) {
            const product = {
                docType: 'product',
                emissionData: data.initialEmissionData,
                emissionsVerified: false,
                certificates: [],
                feedback: []
            };
            await ctx.stub.putState(data.productId, Buffer.from(JSON.stringify(product)));
        }
    }
    async approveEmissionUpdate(ctx, productId, auditorId, auditReport, emissionData) {
        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`Product ${productId} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());

        if (!product.emissionsVerified) {
            throw new Error(`Emissions for Product ${productId} have not been verified`);
        }

        product.emissionData = emissionData;
        product.certificates.push({
            auditorId: auditorId,
            auditReport: auditReport,
            emissionData: emissionData
        });

        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        return JSON.stringify(product);
    }

    async registerProduct(ctx, productId, initialEmissionData) {
        const product = {
            docType: 'product',
            emissionData: initialEmissionData,
            emissionsVerified: false,
            certificates: [],
            feedback: []
        };
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        return JSON.stringify(product);
    }

    async updateEmissionData(ctx, productId, emissionData) {
        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`Product ${productId} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.emissionData = emissionData;
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        return JSON.stringify(product);
    }

    async verifyEmissions(ctx, productId, auditorId, auditReport) {
        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`Product ${productId} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.emissionsVerified = true;
        product.certificates.push({
            auditorId,
            auditReport
        });
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        return JSON.stringify(product);
    }

    async issueCO2Certificate(ctx, productId, certificateId, emissionAmount) {
        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`Product ${productId} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        if (!product.emissionsVerified) {
            throw new Error(`Emissions for Product ${productId} are not verified`);
        }
        product.certificates.push({
            certificateId,
            emissionAmount
        });
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        return JSON.stringify(product);
    }

    async queryProduct(ctx, productId) {
        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`Product ${productId} does not exist`);
        }
        return productAsBytes.toString();
    }

    async consumerFeedback(ctx, productId, consumerId, feedback) {
        const productAsBytes = await ctx.stub.getState(productId);
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`Product ${productId} does not exist`);
        }
        const product = JSON.parse(productAsBytes.toString());
        product.feedback.push({ consumerId, feedback });
        await ctx.stub.putState(productId, Buffer.from(JSON.stringify(product)));
        return JSON.stringify(product);
    }
}

module.exports = AssetTransfer;
