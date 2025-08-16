# Environment Setup Guide
**EUR/USD Trading Platform - Secure Configuration Guide**

> ⚠️ **SECURITY NOTICE**: This guide contains NO hardcoded credentials. All sensitive values must be configured through environment variables or secure secret management systems.

## Overview

This document provides secure environment configuration for the EUR/USD trading platform. Follow these steps to set up development, staging, and production environments without exposing sensitive credentials.

## Prerequisites

- **Node.js**: v18.x or higher (specified in `.nvmrc`)
- **npm**: v9.x or higher
- **Docker**: v20.x or higher (for containerized deployment)
- **Access to secret management system**: Azure Key Vault, AWS Secrets Manager, or HashiCorp Vault

## Environment Types

### 🔧 Development Environment

**Purpose**: Local development with sandbox APIs and test data

#### Required Environment Variables

Create a `.env.development` file (excluded from Git) with these variables:

```bash
# Trading Environment Configuration
NODE_ENV=development
TRADING_ENVIRONMENT=sandbox
LOG_LEVEL=debug

# Broker Configuration (Sandbox)
BROKER_API_KEY=your_sandbox_api_key_here
BROKER_SECRET_KEY=your_sandbox_secret_here
BROKER_ENDPOINT=https://api-sandbox.broker.com/v1
BROKER_TIMEOUT=5000
BROKER_RETRY_ATTEMPTS=3

# Market Data Provider (Test Environment)
MARKET_DATA_TOKEN=your_test_token_here
MARKET_DATA_WS_URL=wss://stream-test.market-data.com
MARKET_DATA_REST_URL=https://api-test.market-data.com/v1
MARKET_DATA_FREQUENCY=tick

# Database Configuration (Local)
DATABASE_URL=mongodb://localhost:27017/eur_usd_trading_dev
REDIS_URL=redis://localhost:6379

# Security Configuration
JWT_SECRET=your_development_jwt_secret_min_32_chars
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
ENCRYPTION_SALT_ROUNDS=12

# Rate Limiting
API_RATE_LIMIT_PER_MINUTE=100
API_BURST_LIMIT=10

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# Trading Parameters (Conservative for Development)
MAX_POSITION_SIZE=10000
MAX_DAILY_LOSS=500
DEFAULT_STOP_LOSS=0.01
SLIPPAGE_TOLERANCE=0.001
EXECUTION_TIMEOUT=3000

# Monitoring (Disabled in Development)
MONITORING_ENABLED=false
```

#### Setup Commands

```bash
# Install dependencies
npm install

# Copy environment template
cp .env.development.example .env.development

# Edit with your sandbox credentials
nano .env.development

# Start development server
npm run dev
```

### 🔄 Staging Environment

**Purpose**: Pre-production testing with production-like data but isolated infrastructure

#### Environment Variable Configuration

**Via Docker Compose** (recommended for staging):

```yaml
# docker-compose.staging.yml
version: '3.8'
services:
  trading-platform:
    image: eur-usd-trading:latest
    environment:
      - NODE_ENV=staging
      - TRADING_ENVIRONMENT=staging
      - BROKER_API_KEY=${STAGING_BROKER_API_KEY}
      - BROKER_SECRET_KEY=${STAGING_BROKER_SECRET}
      - BROKER_ENDPOINT=${STAGING_BROKER_ENDPOINT}
      - DATABASE_URL=${STAGING_DATABASE_URL}
      - JWT_SECRET=${STAGING_JWT_SECRET}
      # Additional staging-specific variables...
```

**Via Secret Management** (Azure Key Vault example):

```bash
# Retrieve secrets from Azure Key Vault
az keyvault secret show --name "staging-broker-api-key" --vault-name "trading-platform-vault" --query "value"
az keyvault secret show --name "staging-database-url" --vault-name "trading-platform-vault" --query "value"
```

#### Staging-Specific Configuration

```bash
# Staging environment variables (managed via secret store)
NODE_ENV=staging
TRADING_ENVIRONMENT=staging
LOG_LEVEL=info

# Higher performance limits for staging
MAX_POSITION_SIZE=50000
MAX_DAILY_LOSS=2500
API_RATE_LIMIT_PER_MINUTE=500

# Monitoring enabled
MONITORING_ENABLED=true
MONITORING_ENDPOINT=https://monitoring-staging.yourcompany.com
```

### 🚀 Production Environment

**Purpose**: Live trading environment with real money and maximum security

#### Security Requirements

- **All secrets MUST be managed via external secret management system**
- **No environment files committed to repository**
- **Encrypted communication for all APIs**
- **Audit logging enabled for all operations**

#### Production Deployment via Kubernetes

```yaml
# k8s/production/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eur-usd-trading-prod
spec:
  template:
    spec:
      containers:
      - name: trading-platform
        image: eur-usd-trading:v1.2.0
        env:
        - name: NODE_ENV
          value: "production"
        - name: TRADING_ENVIRONMENT
          value: "production"
        - name: BROKER_API_KEY
          valueFrom:
            secretKeyRef:
              name: broker-credentials
              key: api-key
        - name: BROKER_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: broker-credentials
              key: secret-key
        # Additional secret references...
```

#### Production Configuration Values

```bash
# Production environment (all values from secret management)
NODE_ENV=production
TRADING_ENVIRONMENT=production
LOG_LEVEL=warn

# Maximum security settings
ENCRYPTION_SALT_ROUNDS=15
JWT_EXPIRES_IN=5m
JWT_REFRESH_EXPIRES_IN=1d

# Production trading limits
MAX_POSITION_SIZE=100000
MAX_DAILY_LOSS=5000
API_RATE_LIMIT_PER_MINUTE=1000

# Enhanced monitoring
MONITORING_ENABLED=true
MONITORING_SAMPLE_RATE=1.0
```

## Secret Management Integration

### Azure Key Vault Integration

```javascript
// utils/secretManager.js
import { SecretClient } from '@azure/keyvault-secrets';
import { DefaultAzureCredential } from '@azure/identity';

const credential = new DefaultAzureCredential();
const vaultName = process.env.AZURE_VAULT_NAME;
const client = new SecretClient(`https://${vaultName}.vault.azure.net/`, credential);

export const getSecret = async (secretName) => {
  try {
    const secret = await client.getSecret(secretName);
    return secret.value;
  } catch (error) {
    console.error(`Failed to retrieve secret ${secretName}:`, error);
    throw error;
  }
};
```

### AWS Secrets Manager Integration

```javascript
// utils/awsSecrets.js
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: process.env.AWS_REGION });

export const getAWSSecret = async (secretArn) => {
  try {
    const command = new GetSecretValueCommand({ SecretId: secretArn });
    const response = await client.send(command);
    return JSON.parse(response.SecretString);
  } catch (error) {
    console.error(`Failed to retrieve AWS secret ${secretArn}:`, error);
    throw error;
  }
};
```

## Environment Validation

### Automated Configuration Validation

```javascript
// scripts/validateEnvironment.js
const requiredVariables = {
  development: [
    'BROKER_API_KEY', 'BROKER_SECRET_KEY', 'BROKER_ENDPOINT',
    'MARKET_DATA_TOKEN', 'DATABASE_URL', 'JWT_SECRET'
  ],
  staging: [
    'BROKER_API_KEY', 'BROKER_SECRET_KEY', 'BROKER_ENDPOINT',
    'MARKET_DATA_TOKEN', 'DATABASE_URL', 'JWT_SECRET',
    'MONITORING_ENDPOINT'
  ],
  production: [
    'BROKER_API_KEY', 'BROKER_SECRET_KEY', 'BROKER_ENDPOINT',
    'MARKET_DATA_TOKEN', 'DATABASE_URL', 'JWT_SECRET',
    'MONITORING_ENDPOINT', 'AZURE_VAULT_NAME'
  ]
};

export const validateEnvironment = (env = process.env.NODE_ENV) => {
  const required = requiredVariables[env] || requiredVariables.development;
  const missing = required.filter(variable => !process.env[variable]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables for ${env}: ${missing.join(', ')}`);
  }
  
  console.log(`✅ Environment validation passed for ${env}`);
  return true;
};
```

## Security Best Practices

### 🔒 Credential Management

1. **Never commit credentials to Git**
   - Use `.gitignore` to exclude `.env*` files
   - Use `git-secrets` or similar tools to prevent accidents

2. **Rotate credentials regularly**
   - API keys: Every 90 days
   - JWT secrets: Every 30 days
   - Database passwords: Every 180 days

3. **Use principle of least privilege**
   - Separate API keys for different environments
   - Limited scope permissions for each service

### 🔍 Monitoring and Auditing

1. **Environment access logging**
   ```bash
   # Log environment variable access
   export LOG_ENV_ACCESS=true
   ```

2. **Secret rotation alerts**
   ```javascript
   // Monitor secret age and alert for rotation
   const checkSecretAge = async () => {
     const secretAge = await getSecretMetadata('broker-api-key');
     if (secretAge > 90) {
       await sendAlert('Secret rotation required', 'broker-api-key');
     }
   };
   ```

### 🚨 Emergency Procedures

#### Credential Compromise Response

1. **Immediate actions** (within 1 hour):
   - Revoke compromised credentials
   - Generate new credentials
   - Update all environments
   - Monitor for unauthorized access

2. **Investigation** (within 24 hours):
   - Audit access logs
   - Identify potential impact
   - Document incident

3. **Prevention** (within 1 week):
   - Update security procedures
   - Enhance monitoring
   - Team security training

## Quick Start Checklist

### For New Developers

- [ ] Install required dependencies (Node.js, Docker)
- [ ] Clone repository
- [ ] Create `.env.development` from template
- [ ] Obtain sandbox API credentials from team lead
- [ ] Run `npm run validate-env` to verify configuration
- [ ] Start development server with `npm run dev`
- [ ] Verify trading functionality with test endpoints

### For DevOps Engineers

- [ ] Set up secret management system (Azure Key Vault/AWS Secrets Manager)
- [ ] Configure production secrets
- [ ] Set up monitoring and alerting
- [ ] Configure automated secret rotation
- [ ] Test disaster recovery procedures
- [ ] Document operational procedures

## Troubleshooting

### Common Issues

**Environment Variables Not Loading**
```bash
# Check if environment file exists and is readable
ls -la .env*
cat .env.development | head -5

# Verify environment variables are loaded
node -e "console.log(process.env.BROKER_API_KEY ? 'Loaded' : 'Missing')"
```

**API Connection Failures**
```bash
# Test broker API connectivity
curl -H "Authorization: Bearer ${BROKER_API_KEY}" ${BROKER_ENDPOINT}/health

# Test market data WebSocket
wscat -c "${MARKET_DATA_WS_URL}?token=${MARKET_DATA_TOKEN}"
```

**Database Connection Issues**
```bash
# Test database connectivity
mongosh "${DATABASE_URL}" --eval "db.adminCommand('ismaster')"
```

## Support and Contact

For environment setup issues:
- **Development**: Contact DevOps team via Slack #trading-platform-dev
- **Staging/Production**: Create ticket in JIRA project TRADING-OPS
- **Security concerns**: Email security@yourcompany.com immediately

---

**Last Updated**: 2025-08-15  
**Document Version**: v2.1.0  
**Next Review**: 2025-09-15
