// Jest test setup
import dotenv from 'dotenv';

// Load test environment variables
dotenv.config({ path: '.env.test' });

// Mock Azure services for testing
process.env.COSMOS_DB_ENDPOINT = 'https://test-cosmos.documents.azure.com:443/';
process.env.COSMOS_DB_KEY = 'test-key';
process.env.COSMOS_DB_DATABASE = 'test-db';
process.env.AZURE_AD_B2C_CLIENT_ID = 'test-client-id';
process.env.AZURE_AD_B2C_CLIENT_SECRET = 'test-client-secret';
process.env.AZURE_AD_B2C_TENANT_ID = 'test-tenant.onmicrosoft.com';
process.env.JWT_SECRET = 'test-jwt-secret';

// Global test utilities
global.testUser = {
    _id: '507f1f77bcf86cd799439011',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'client',
    azureB2CId: 'test-azure-id'
};

global.testPet = {
    _id: '507f1f77bcf86cd799439012',
    name: 'Max',
    species: 'dog',
    ownerId: '507f1f77bcf86cd799439011'
};

// Cleanup after each test
afterEach(() => {
    jest.clearAllMocks();
});
