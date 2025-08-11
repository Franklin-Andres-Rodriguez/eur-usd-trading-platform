# 🔧 Environment Configuration Guide

## 📋 **Overview**

This guide provides comprehensive instructions for configuring the EUR/USD Trading Platform's environment variables, following **industry-standard security practices** and **professional development workflows**.

**Why Environment Configuration Matters for Financial Software:**
- 🔒 **Security:** API keys and secrets never exposed in source code
- 🚀 **Deployment:** Same codebase works across development, staging, and production
- 👥 **Team Collaboration:** Standardized setup process for all developers
- 📊 **Compliance:** Meets financial industry regulatory requirements
- ⚡ **Performance:** Environment-specific optimizations and feature flags

---

## 🚀 **Quick Setup (5 Minutes)**

### **Step 1: Copy Environment Template**
```bash
# Copy the example file to create your local configuration
cp .env.example .env
```

### **Step 2: Get Alpha Vantage API Key**
1. Visit [Alpha Vantage API Registration](https://www.alphavantage.co/support/#api-key)
2. Sign up for a free account
3. Copy your API key (format: `ABC123XYZ789`)

### **Step 3: Configure Your .env File**
```bash
# Open .env in your preferred editor
nano .env
# or
code .env
# or  
vim .env
```

**Replace this line:**
```bash
ALPHA_VANTAGE_API_KEY=demo
```

**With your actual API key:**
```bash
ALPHA_VANTAGE_API_KEY=your_actual_api_key_here
```

### **Step 4: Verify Configuration**
```bash
# Test that configuration loads correctly
npm run test:config

# Start development server
npm run dev
```

**✅ Success Indicators:**
- Application starts without configuration errors
- Real market data loads (not demo data)
- No security warnings in console

---

## 📁 **File Structure**

```
📦 eur-usd-trading/
├── 📄 .env.example          # Template (committed to repo)
├── 📄 .env                  # Your config (git-ignored)
├── 📄 .gitignore            # Protects secrets
└── 📁 src/
    └── 📁 config/
        └── 📄 environment.js # Configuration loader
```

### **File Purposes**

| File | Purpose | Version Control | Contains Secrets |
|------|---------|----------------|------------------|
| `.env.example` | Template for new developers | ✅ Committed | ❌ No secrets |
| `.env` | Your actual configuration | ❌ Git-ignored | ⚠️ Contains API keys |
| `environment.js` | Configuration loader | ✅ Committed | ❌ No secrets |

---

## 🔧 **Configuration Categories**

### **📊 Market Data API Settings**
```bash
# Alpha Vantage Configuration
ALPHA_VANTAGE_API_KEY=your_api_key_here
ALPHA_VANTAGE_API_URL=https://www.alphavantage.co/query
API_RATE_LIMIT=5
API_TIMEOUT=5000
API_MAX_RETRIES=3
API_RETRY_DELAY=1000
```

**Rate Limits by Plan:**
- **Free:** 5 requests/minute, 500 requests/day
- **Standard:** 15 requests/minute, 1,200 requests/day  
- **Premium:** 75 requests/minute, 3,600 requests/day

### **💾 Caching Settings**
```bash
# Caching Configuration
CACHE_STRATEGY=memory          # memory, localStorage, none
CACHE_TIMEOUT=300000          # 5 minutes in milliseconds
CACHE_ENABLED=true
CACHE_MAX_ENTRIES=1000
```

**Cache Strategy Comparison:**

| Strategy | Speed | Persistence | Storage Limit | Best For |
|----------|-------|-------------|---------------|----------|
| `memory` | ⚡ Fastest | ❌ Lost on refresh | 🚫 RAM limited | Development |
| `localStorage` | 🔥 Fast | ✅ Persists | 📊 ~5-10MB | Production |
| `none` | 🐌 Slowest | ❌ No caching | 🚫 N/A | Debugging |

### **🚀 Feature Flags**
```bash
# Core Features
ENABLE_PRICE_ALERTS=true
ENABLE_TECHNICAL_INDICATORS=true
ENABLE_CHART_EXPORT=true
ENABLE_DARK_MODE=true

# Advanced Features (Future Phases)
ENABLE_WEBSOCKET=false
ENABLE_MACHINE_LEARNING=false
ENABLE_SOCIAL_FEATURES=false
```

**Feature Flag Benefits:**
- 🧪 **A/B Testing:** Enable features for specific user groups
- 🚀 **Gradual Rollout:** Launch features incrementally
- 🛡️ **Risk Mitigation:** Quickly disable problematic features
- 👥 **Team Development:** Work on features without affecting others

### **🔒 Security Configuration**
```bash
# Security Settings
CORS_ORIGINS=http://localhost:3000,http://localhost:3001
CSP_LEVEL=moderate
SESSION_SECRET=your_session_secret_minimum_32_characters
```

**Security Levels:**

| Level | Description | CORS | CSP | Best For |
|-------|-------------|------|-----|----------|
| `strict` | Maximum security | Same-origin only | Restrictive | Production |
| `moderate` | Balanced | Listed origins | Balanced | Development |
| `permissive` | Minimal restrictions | All origins | Relaxed | Testing only |

---

## 🌍 **Environment-Specific Configurations**

### **🔬 Development Environment**
```bash
# Development (.env)
NODE_ENV=development
DEBUG_MODE=true
LOG_LEVEL=debug
API_RATE_LIMIT=5
CACHE_STRATEGY=memory
ENABLE_HMR=true
GENERATE_SOURCEMAP=true
```

**Development Features:**
- 🐛 **Detailed Logging:** Debug-level logs for troubleshooting
- 🔄 **Hot Module Replacement:** Instant code updates
- 🗺️ **Source Maps:** Easy debugging in browser DevTools
- 💾 **Memory Caching:** Fast development feedback

### **🧪 Staging Environment**
```bash
# Staging (.env.staging)
NODE_ENV=staging
DEBUG_MODE=false
LOG_LEVEL=warn
API_RATE_LIMIT=15
CACHE_STRATEGY=localStorage
ENABLE_PERFORMANCE_MONITORING=true
```

**Staging Purpose:**
- 🎭 **Production Simulation:** Test with production-like settings
- 📊 **Performance Testing:** Monitor real-world performance
- 🔍 **Integration Testing:** Verify external API integrations
- 👥 **User Acceptance Testing:** Client preview environment

### **🚀 Production Environment**
```bash
# Production (.env.production)
NODE_ENV=production
DEBUG_MODE=false
LOG_LEVEL=error
API_RATE_LIMIT=75
CACHE_STRATEGY=localStorage
ENABLE_COMPRESSION=true
AUDIT_ENABLED=true
```

**Production Requirements:**
- 🔒 **Security Hardened:** Minimal logging, strict CORS
- ⚡ **Performance Optimized:** Compression, efficient caching
- 📋 **Compliance Ready:** Audit logging, error tracking
- 🛡️ **Fault Tolerant:** Graceful error handling, monitoring

---

## 🔧 **Configuration Usage in Code**

### **Basic Usage**
```javascript
import { getConfig } from '../config/environment.js';

const config = getConfig();

// Access configuration values
const apiKey = config.api.alphaVantage.apiKey;
const cacheTimeout = config.cache.timeout;
const isDarkModeEnabled = config.features.darkMode;
```

### **Feature Flag Checking**
```javascript
import { configHelpers } from '../config/environment.js';

// Check if feature is enabled
if (configHelpers.isFeatureEnabled('priceAlerts')) {
  // Initialize price alert functionality
  initializePriceAlerts();
}

// Environment-specific behavior
if (configHelpers.isEnvironment('development')) {
  console.log('Running in development mode');
}
```

### **Environment-Safe API Calls**
```javascript
const fetchPriceData = async (pair) => {
  const config = getConfig();
  
  try {
    const response = await fetch(`${config.api.alphaVantage.baseUrl}?` +
      new URLSearchParams({
        function: 'FX_INTRADAY',
        from_symbol: 'EUR',
        to_symbol: 'USD',
        interval: '1min',
        apikey: config.api.alphaVantage.apiKey
      }), {
        timeout: config.api.alphaVantage.timeout,
      }
    );
    
    if (!response.ok) {
      throw new Error(`API Error: ${response.status}`);
    }
    
    return await response.json();
    
  } catch (error) {
    // Safe error logging (no API key exposure)
    console.error('Price fetch failed:', error.message);
    throw new Error('Unable to fetch price data');
  }
};
```

---

## 🧪 **Testing Your Configuration**

### **Configuration Validation Script**
Create `scripts/test-config.js`:
```javascript
import { getConfig, configHelpers } from '../src/config/environment.js';

console.log('🧪 Testing Configuration...\n');

try {
  const config = getConfig();
  const summary = configHelpers.getSummary();
  
  console.log('✅ Configuration loaded successfully');
  console.log('📊 Summary:', summary);
  
  // Test API key
  if (summary.hasApiKey) {
    console.log('✅ API key configured');
  } else {
    console.log('⚠️  Using demo API key');
  }
  
  // Test feature flags
  const enabledFeatures = summary.enabledFeatures;
  console.log(`✅ ${enabledFeatures.length} features enabled:`, enabledFeatures);
  
  console.log('\n🎉 Configuration test passed!');
  
} catch (error) {
  console.error('❌ Configuration test failed:', error.message);
  process.exit(1);
}
```

### **Run Configuration Tests**
```bash
# Add to package.json scripts:
"test:config": "node scripts/test-config.js"

# Run the test
npm run test:config
```

---

## 🚨 **Security Best Practices**

### **🔐 API Key Management**

**✅ DO:**
- Use environment variables for all API keys
- Rotate API keys regularly (quarterly recommended)
- Use different API keys for different environments
- Monitor API key usage and set up alerts

**❌ DON'T:**
- Hardcode API keys in source code
- Share API keys via email or chat
- Use production API keys in development
- Commit .env files to version control

### **🛡️ Environment Variable Security**
```bash
# ✅ Good: Descriptive but secure
ALPHA_VANTAGE_API_KEY=abc123def456
DATABASE_URL=postgresql://user:pass@localhost/db

# ❌ Bad: Exposed in code
const API_KEY = 'abc123def456'; // Never do this!
```

### **🔍 Security Validation Checklist**
- [ ] `.env` file is in `.gitignore`
- [ ] No API keys in source code
- [ ] Different keys for each environment
- [ ] API key format validation in loader
- [ ] Error messages don't expose secrets
- [ ] Session secrets are cryptographically secure
- [ ] CORS origins are restrictive in production

---

## 🐛 **Troubleshooting**

### **Common Issues**

**❌ "Required environment variable ALPHA_VANTAGE_API_KEY is not set"**
```bash
# Check if .env file exists
ls -la .env

# Verify .env contains the key
grep ALPHA_VANTAGE_API_KEY .env

# Copy from template if missing
cp .env.example .env
```

**❌ "Invalid or missing Alpha Vantage API key in production"**
```bash
# Verify API key format (alphanumeric, 8-32 characters)
echo $ALPHA_VANTAGE_API_KEY | grep -E '^[A-Za-z0-9]{8,32}$'

# Test API key manually
curl "https://www.alphavantage.co/query?function=FX_INTRADAY&from_symbol=EUR&to_symbol=USD&interval=1min&apikey=YOUR_KEY"
```

**❌ "Cache strategy 'invalid' not supported"**
```bash
# Check valid cache strategies
grep -n CACHE_STRATEGY .env.example

# Fix: Use one of: memory, localStorage, none
CACHE_STRATEGY=memory
```

### **Debug Mode**
```bash
# Enable debug mode for detailed logs
DEBUG_MODE=true
LOG_LEVEL=debug

# Start application and check console
npm run dev
```

### **Configuration Summary**
```javascript
// In browser console, check current config
import('./src/config/environment.js').then(({ configHelpers }) => {
  console.log(configHelpers.getSummary());
});
```

---

## 👥 **Team Onboarding**

### **For New Team Members**

**📋 Onboarding Checklist:**
1. [ ] Clone repository
2. [ ] Copy `.env.example` to `.env`
3. [ ] Obtain Alpha Vantage API key
4. [ ] Configure `.env` with personal API key
5. [ ] Run `npm run test:config`
6. [ ] Start development server: `npm run dev`
7. [ ] Verify real market data loads

### **Team Lead Responsibilities**
- 🔑 **API Key Management:** Provide guidance on obtaining API keys
- 📚 **Documentation:** Keep this guide updated with new variables
- 🛡️ **Security Training:** Educate team on security best practices
- 🔍 **Code Reviews:** Check for hardcoded secrets in PRs

### **Onboarding Script**
Create `scripts/onboard.js`:
```javascript
#!/usr/bin/env node

console.log('🎉 Welcome to EUR/USD Trading Platform!');
console.log('\n📋 Setting up your development environment...\n');

// Check if .env exists
if (!fs.existsSync('.env')) {
  console.log('📄 Creating .env from template...');
  fs.copyFileSync('.env.example', '.env');
  console.log('✅ .env file created');
} else {
  console.log('✅ .env file already exists');
}

console.log('\n🔑 Next steps:');
console.log('1. Get your Alpha Vantage API key: https://www.alphavantage.co/support/#api-key');
console.log('2. Edit .env and replace ALPHA_VANTAGE_API_KEY=demo with your real key');
console.log('3. Run: npm run test:config');
console.log('4. Run: npm run dev');
console.log('\n📚 Need help? Check docs/ENVIRONMENT_SETUP.md');
```

---

## 📊 **Monitoring & Maintenance**

### **Configuration Health Checks**
```javascript
// Health check endpoint
app.get('/health/config', (req, res) => {
  try {
    const summary = configHelpers.getSummary();
    res.json({
      status: 'healthy',
      environment: summary.environment,
      hasApiKey: summary.hasApiKey,
      enabledFeatures: summary.enabledFeatures.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      error: 'Configuration validation failed'
    });
  }
});
```

### **API Key Rotation Process**
1. **Generate New Key:** Get replacement from Alpha Vantage
2. **Update Staging:** Test with new key in staging environment
3. **Update Production:** Deploy with new key during maintenance window
4. **Verify Operation:** Confirm all services working with new key
5. **Revoke Old Key:** Disable old key after confirmation

### **Regular Maintenance Tasks**
- 🔄 **Monthly:** Review and rotate API keys
- 📊 **Weekly:** Check configuration health in all environments
- 🔍 **Daily:** Monitor error logs for configuration issues
- 📋 **Quarterly:** Review and update environment documentation

---

## 📚 **Additional Resources**

### **External Documentation**
- [Alpha Vantage API Documentation](https://www.alphavantage.co/documentation/)
- [12-Factor App Environment Configuration](https://12factor.net/config)
- [OWASP Environment Security Guide](https://owasp.org/www-project-top-ten/)

### **Internal Documentation**
- [Architecture Overview](ARCHITECTURE.md)
- [Development Guidelines](CONTRIBUTING.md)
- [Security Handbook](SECURITY.md)
- [Deployment Guide](DEPLOYMENT.md)

### **Quick Reference**
```bash
# Common Commands
cp .env.example .env              # Setup new environment
npm run test:config              # Validate configuration
npm run dev                      # Start development server
grep -v "^#" .env | sort        # View current settings
```

---

**🎯 Remember:** Environment configuration is the foundation of professional software development. Taking time to set it up correctly prevents security issues, deployment problems, and team collaboration friction. When in doubt, prioritize security over convenience.**
