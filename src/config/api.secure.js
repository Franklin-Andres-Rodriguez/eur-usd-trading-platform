/**
 * SECURE API CONFIGURATION TEMPLATE
 * EUR/USD Trading Platform - Production Ready
 *
 * CRITICAL: Never commit actual credentials to version control
 * Use environment variables for all sensitive data
 */

// Environment validation with detailed error messages
const requiredEnvVars = [
  'BROKER_API_KEY',
  'BROKER_SECRET_KEY',
  'BROKER_ENDPOINT',
  'MARKET_DATA_TOKEN',
  'MARKET_DATA_WS_URL',
  'TRADING_ENVIRONMENT', // 'sandbox' | 'production'
  'API_RATE_LIMIT_PER_MINUTE'
];

const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
if (missingVars.length > 0) {
  throw new Error(`Missing required environment variables: ${missingVars.join(', ')}`);
}

// Secure configuration object with validation
const API_CONFIG = {
  broker: {
    // Primary trading broker configuration
    key: process.env.BROKER_API_KEY,
    secret: process.env.BROKER_SECRET_KEY,
    endpoint: process.env.BROKER_ENDPOINT,
    timeout: parseInt(process.env.BROKER_TIMEOUT) || 5000,
    retryAttempts: parseInt(process.env.BROKER_RETRY_ATTEMPTS) || 3,

    // Rate limiting for financial APIs (critical for trading)
    rateLimit: {
      requestsPerMinute: parseInt(process.env.API_RATE_LIMIT_PER_MINUTE) || 100,
      burstLimit: parseInt(process.env.API_BURST_LIMIT) || 10
    },

    // Circuit breaker configuration for market volatility
    circuitBreaker: {
      failureThreshold: parseInt(process.env.CIRCUIT_BREAKER_THRESHOLD) || 5,
      recoveryTimeout: parseInt(process.env.CIRCUIT_BREAKER_RECOVERY) || 30000
    }
  },

  marketData: {
    // Real-time market data provider
    token: process.env.MARKET_DATA_TOKEN,
    wsUrl: process.env.MARKET_DATA_WS_URL,
    restUrl: process.env.MARKET_DATA_REST_URL,

    // Subscription configuration for EUR/USD pair
    subscriptions: {
      symbols: ['EURUSD', 'EURJPY', 'EURGBP'], // Major EUR pairs
      dataTypes: ['bid', 'ask', 'volume', 'timestamp'],
      updateFrequency: process.env.MARKET_DATA_FREQUENCY || 'tick' // 'tick' | '1s' | '5s'
    }
  },

  security: {
    // API security configuration
    encryption: {
      algorithm: 'aes-256-gcm',
      keyDerivation: 'pbkdf2',
      saltRounds: parseInt(process.env.ENCRYPTION_SALT_ROUNDS) || 12
    },

    // JWT configuration for user sessions
    jwt: {
      secret: process.env.JWT_SECRET,
      expiresIn: process.env.JWT_EXPIRES_IN || '15m',
      refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d'
    },

    // CORS configuration for trading interface
    cors: {
      origin: process.env.ALLOWED_ORIGINS?.split(',') || ['https://trading.yourcompany.com'],
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Trading-Session']
    }
  },

  environment: {
    // Environment-specific settings
    nodeEnv: process.env.NODE_ENV || 'development',
    tradingEnv: process.env.TRADING_ENVIRONMENT || 'sandbox',
    logLevel: process.env.LOG_LEVEL || 'info',

    // Performance monitoring
    monitoring: {
      enabled: process.env.MONITORING_ENABLED === 'true',
      endpoint: process.env.MONITORING_ENDPOINT,
      sampleRate: parseFloat(process.env.MONITORING_SAMPLE_RATE) || 0.1
    }
  },

  // Trading-specific configuration
  trading: {
    // Risk management parameters
    maxPositionSize: parseFloat(process.env.MAX_POSITION_SIZE) || 100000, // EUR
    maxDailyLoss: parseFloat(process.env.MAX_DAILY_LOSS) || 5000, // EUR
    stopLossDefault: parseFloat(process.env.DEFAULT_STOP_LOSS) || 0.01, // 1%

    // Order execution settings
    slippageTolerance: parseFloat(process.env.SLIPPAGE_TOLERANCE) || 0.0005, // 5 pips
    executionTimeout: parseInt(process.env.EXECUTION_TIMEOUT) || 3000, // 3 seconds

    // Market hours (UTC)
    marketHours: {
      start: process.env.MARKET_START_UTC || '22:00', // Sunday 22:00 UTC
      end: process.env.MARKET_END_UTC || '22:00'      // Friday 22:00 UTC
    }
  }
};

// Configuration validation for critical trading parameters
const validateConfig = () => {
  const errors = [];

  // Validate trading environment
  if (!['sandbox', 'production'].includes(API_CONFIG.environment.tradingEnv)) {
    errors.push('TRADING_ENVIRONMENT must be either "sandbox" or "production"');
  }

  // Validate broker endpoint format
  if (!API_CONFIG.broker.endpoint.startsWith('https://')) {
    errors.push('BROKER_ENDPOINT must use HTTPS protocol');
  }

  // Validate market data WebSocket URL
  if (!API_CONFIG.marketData.wsUrl.startsWith('wss://')) {
    errors.push('MARKET_DATA_WS_URL must use secure WebSocket protocol (wss://)');
  }

  // Validate JWT secret strength
  if (!API_CONFIG.security.jwt.secret || API_CONFIG.security.jwt.secret.length < 32) {
    errors.push('JWT_SECRET must be at least 32 characters long');
  }

  // Validate trading limits
  if (API_CONFIG.trading.maxPositionSize <= 0) {
    errors.push('MAX_POSITION_SIZE must be greater than 0');
  }

  if (errors.length > 0) {
    throw new Error(`Configuration validation failed:\n${errors.join('\n')}`);
  }
};

// Validate configuration on module load
validateConfig();

// Export configuration with runtime environment info
export default {
  ...API_CONFIG,

  // Runtime metadata (safe to log)
  metadata: {
    configLoadedAt: new Date().toISOString(),
    environment: API_CONFIG.environment.tradingEnv,
    nodeEnv: API_CONFIG.environment.nodeEnv,
    version: process.env.npm_package_version || 'unknown'
  },

  // Safe configuration for logging (no secrets)
  getSafeConfig: () => ({
    broker: {
      endpoint: API_CONFIG.broker.endpoint,
      timeout: API_CONFIG.broker.timeout,
      rateLimit: API_CONFIG.broker.rateLimit
    },
    marketData: {
      restUrl: API_CONFIG.marketData.restUrl,
      subscriptions: API_CONFIG.marketData.subscriptions
    },
    trading: API_CONFIG.trading,
    environment: API_CONFIG.environment
  })
};

/**
 * USAGE EXAMPLE:
 *
 * import config from './config/api.secure.js';
 *
 * // Use in broker connection
 * const brokerClient = new BrokerClient({
 *   apiKey: config.broker.key,
 *   secret: config.broker.secret,
 *   endpoint: config.broker.endpoint
 * });
 *
 * // Log safe configuration for debugging
 * console.log('Loaded configuration:', config.getSafeConfig());
 */
