/**
 * Environment Configuration Loader
 * ================================
 * 
 * Centralized configuration management following Clean Architecture principles.
 * Provides type-safe configuration loading with validation and sensible defaults.
 * 
 * Design Principles Applied:
 * - Single Responsibility: Only handles configuration loading
 * - Dependency Inversion: Application depends on this abstraction
 * - Fail Fast: Invalid configuration throws errors immediately
 * - Security First: No secrets logged or exposed
 * 
 * @author EUR/USD Trading Platform Team
 * @version 1.0.0
 */

// Environment Detection
const isDevelopment = () => process.env.NODE_ENV === 'development';
const isProduction = () => process.env.NODE_ENV === 'production';
const isTest = () => process.env.NODE_ENV === 'test';

/**
 * Load and validate environment variable with type conversion
 * @param {string} key - Environment variable name
 * @param {*} defaultValue - Default value if env var not set
 * @param {string} type - Expected type (string, number, boolean, array)
 * @param {boolean} required - Whether this variable is required
 * @returns {*} Parsed and validated value
 * @throws {Error} If required variable is missing or invalid type
 */
const loadEnvVar = (key, defaultValue, type = 'string', required = false) => {
  const value = process.env[key];
  
  // Check if required variable is missing
  if (required && (value === undefined || value === '')) {
    throw new Error(
      `Required environment variable ${key} is not set. ` +
      `Check your .env file or environment configuration.`
    );
  }
  
  // Use default if not set
  if (value === undefined || value === '') {
    return defaultValue;
  }
  
  // Type conversion with validation
  try {
    switch (type) {
      case 'string':
        return value;
        
      case 'number':
        const num = Number(value);
        if (isNaN(num)) {
          throw new Error(`${key} must be a valid number, got: ${value}`);
        }
        return num;
        
      case 'boolean':
        if (value.toLowerCase() === 'true') return true;
        if (value.toLowerCase() === 'false') return false;
        throw new Error(`${key} must be 'true' or 'false', got: ${value}`);
        
      case 'array':
        return value.split(',').map(item => item.trim()).filter(Boolean);
        
      default:
        throw new Error(`Unsupported type ${type} for environment variable ${key}`);
    }
  } catch (error) {
    throw new Error(
      `Invalid configuration for ${key}: ${error.message}. ` +
      `Please check your .env file.`
    );
  }
};

/**
 * Validate API key format (basic security check)
 * @param {string} apiKey - API key to validate
 * @returns {boolean} Whether API key appears valid
 */
const isValidApiKey = (apiKey) => {
  if (!apiKey || apiKey === 'your_api_key_here' || apiKey === 'demo') {
    return false;
  }
  
  // Alpha Vantage keys are typically alphanumeric, 8-32 characters
  const apiKeyPattern = /^[A-Za-z0-9]{8,32}$/;
  return apiKeyPattern.test(apiKey);
};

/**
 * Create configuration object with all application settings
 * Organized by domain for better maintainability
 */
const createConfig = () => {
  try {
    const config = {
      // =================================================================
      // APPLICATION CORE SETTINGS
      // =================================================================
      app: {
        environment: loadEnvVar('NODE_ENV', 'development'),
        port: loadEnvVar('PORT', 3000, 'number'),
        baseUrl: loadEnvVar('APP_BASE_URL', 'http://localhost:3000'),
        debugMode: loadEnvVar('DEBUG_MODE', isDevelopment(), 'boolean'),
        version: process.env.npm_package_version || '1.0.0',
      },

      // =================================================================
      // MARKET DATA API CONFIGURATION
      // =================================================================
      api: {
        alphaVantage: {
          apiKey: loadEnvVar('ALPHA_VANTAGE_API_KEY', '', 'string', true),
          baseUrl: loadEnvVar('ALPHA_VANTAGE_API_URL', 'https://www.alphavantage.co/query'),
          rateLimit: loadEnvVar('API_RATE_LIMIT', 5, 'number'),
          timeout: loadEnvVar('API_TIMEOUT', 5000, 'number'),
          maxRetries: loadEnvVar('API_MAX_RETRIES', 3, 'number'),
          retryDelay: loadEnvVar('API_RETRY_DELAY', 1000, 'number'),
        },
      },

      // =================================================================
      // CACHING CONFIGURATION
      // =================================================================
      cache: {
        strategy: loadEnvVar('CACHE_STRATEGY', 'memory'),
        timeout: loadEnvVar('CACHE_TIMEOUT', 300000, 'number'), // 5 minutes
        enabled: loadEnvVar('CACHE_ENABLED', true, 'boolean'),
        maxEntries: loadEnvVar('CACHE_MAX_ENTRIES', 1000, 'number'),
      },

      // =================================================================
      // SECURITY CONFIGURATION
      // =================================================================
      security: {
        corsOrigins: loadEnvVar('CORS_ORIGINS', 'http://localhost:3000', 'array'),
        cspLevel: loadEnvVar('CSP_LEVEL', 'moderate'),
        sessionSecret: loadEnvVar('SESSION_SECRET', ''),
      },

      // =================================================================
      // FEATURE FLAGS
      // =================================================================
      features: {
        websocket: loadEnvVar('ENABLE_WEBSOCKET', false, 'boolean'),
        pushNotifications: loadEnvVar('ENABLE_PUSH_NOTIFICATIONS', false, 'boolean'),
        priceAlerts: loadEnvVar('ENABLE_PRICE_ALERTS', true, 'boolean'),
        technicalIndicators: loadEnvVar('ENABLE_TECHNICAL_INDICATORS', true, 'boolean'),
        chartExport: loadEnvVar('ENABLE_CHART_EXPORT', true, 'boolean'),
        multipleTimeframes: loadEnvVar('ENABLE_MULTIPLE_TIMEFRAMES', true, 'boolean'),
        machineLearning: loadEnvVar('ENABLE_MACHINE_LEARNING', false, 'boolean'),
        socialFeatures: loadEnvVar('ENABLE_SOCIAL_FEATURES', false, 'boolean'),
        portfolioTracking: loadEnvVar('ENABLE_PORTFOLIO_TRACKING', false, 'boolean'),
        darkMode: loadEnvVar('ENABLE_DARK_MODE', true, 'boolean'),
        responsiveCharts: loadEnvVar('ENABLE_RESPONSIVE_CHARTS', true, 'boolean'),
        accessibility: loadEnvVar('ENABLE_ACCESSIBILITY_FEATURES', true, 'boolean'),
      },

      // =================================================================
      // PERFORMANCE & MONITORING
      // =================================================================
      monitoring: {
        performance: loadEnvVar('ENABLE_PERFORMANCE_MONITORING', true, 'boolean'),
        errorReporting: loadEnvVar('ENABLE_ERROR_REPORTING', true, 'boolean'),
        analytics: loadEnvVar('ENABLE_ANALYTICS', false, 'boolean'),
        lighthouseCI: loadEnvVar('LIGHTHOUSE_CI_ENABLED', false, 'boolean'),
      },

      // =================================================================
      // LOGGING CONFIGURATION
      // =================================================================
      logging: {
        level: loadEnvVar('LOG_LEVEL', isDevelopment() ? 'debug' : 'warn'),
        format: loadEnvVar('LOG_FORMAT', 'simple'),
        apiRequests: loadEnvVar('LOG_API_REQUESTS', isDevelopment(), 'boolean'),
        performance: loadEnvVar('LOG_PERFORMANCE', isDevelopment(), 'boolean'),
      },

      // =================================================================
      // DEVELOPMENT TOOLS
      // =================================================================
      development: {
        hmr: loadEnvVar('ENABLE_HMR', isDevelopment(), 'boolean'),
        sourceMaps: loadEnvVar('GENERATE_SOURCEMAP', isDevelopment(), 'boolean'),
        bundleAnalyzer: loadEnvVar('ANALYZE_BUNDLE', false, 'boolean'),
        mockData: loadEnvVar('USE_MOCK_DATA', false, 'boolean'),
        healthCheck: loadEnvVar('HEALTH_CHECK_ENABLED', true, 'boolean'),
      },

      // =================================================================
      // FINANCIAL PLATFORM SPECIFIC
      // =================================================================
      trading: {
        defaultPair: loadEnvVar('DEFAULT_CURRENCY_PAIR', 'EUR/USD'),
        defaultTimeframe: loadEnvVar('DEFAULT_TIMEFRAME', '1h'),
        maxHistoricalData: loadEnvVar('MAX_HISTORICAL_DATA', 1000, 'number'),
        pricePrecision: loadEnvVar('PRICE_PRECISION', 5, 'number'),
        maxAlertCount: loadEnvVar('MAX_ALERT_COUNT', 10, 'number'),
        rateLimitPerUser: loadEnvVar('RATE_LIMIT_PER_USER', 100, 'number'),
        auditEnabled: loadEnvVar('AUDIT_ENABLED', true, 'boolean'),
        auditLevel: loadEnvVar('AUDIT_LEVEL', 'basic'),
      },
    };

    // =================================================================
    // POST-LOADING VALIDATION
    // =================================================================
    
    // Validate API key in production
    if (isProduction() && !isValidApiKey(config.api.alphaVantage.apiKey)) {
      throw new Error(
        'Invalid or missing Alpha Vantage API key in production environment. ' +
        'Please set ALPHA_VANTAGE_API_KEY to a valid API key.'
      );
    }
    
    // Warn about demo API key in development
    if (isDevelopment() && config.api.alphaVantage.apiKey === 'demo') {
      console.warn(
        '⚠️  Using demo API key. Real market data will not be available. ' +
        'Get your free API key at: https://www.alphavantage.co/support/#api-key'
      );
    }
    
    // Validate session secret in production
    if (isProduction() && config.security.sessionSecret.length < 32) {
      throw new Error(
        'SESSION_SECRET must be at least 32 characters in production. ' +
        'Generate with: node -e "console.log(require(\'crypto\').randomBytes(32).toString(\'hex\'))"'
      );
    }
    
    // Validate port availability
    if (config.app.port < 1 || config.app.port > 65535) {
      throw new Error(`Invalid port number: ${config.app.port}. Must be between 1 and 65535.`);
    }
    
    // Validate cache configuration
    const validCacheStrategies = ['memory', 'localStorage', 'none'];
    if (!validCacheStrategies.includes(config.cache.strategy)) {
      throw new Error(
        `Invalid cache strategy: ${config.cache.strategy}. ` +
        `Must be one of: ${validCacheStrategies.join(', ')}`
      );
    }

    return config;
    
  } catch (error) {
    console.error('❌ Configuration Error:', error.message);
    console.error('\n📋 Troubleshooting:');
    console.error('1. Check that .env file exists in project root');
    console.error('2. Verify all required environment variables are set');
    console.error('3. Ensure API keys are valid and not placeholder values');
    console.error('4. Review .env.example for correct variable names and formats');
    console.error('\n🔧 Quick fix: Copy .env.example to .env and customize values\n');
    
    // Re-throw to prevent application startup with invalid config
    throw error;
  }
};

/**
 * Configuration validation and debugging helpers
 */
const configHelpers = {
  /**
   * Validate current configuration
   * @returns {boolean} Whether configuration is valid
   */
  validate() {
    try {
      createConfig();
      return true;
    } catch {
      return false;
    }
  },

  /**
   * Get configuration summary (safe for logging - no secrets)
   * @returns {object} Configuration summary without sensitive data
   */
  getSummary() {
    const config = getConfig();
    return {
      environment: config.app.environment,
      port: config.app.port,
      apiProvider: config.api.alphaVantage.baseUrl ? 'Alpha Vantage' : 'None',
      hasApiKey: !!config.api.alphaVantage.apiKey && config.api.alphaVantage.apiKey !== 'demo',
      cacheStrategy: config.cache.strategy,
      enabledFeatures: Object.entries(config.features)
        .filter(([, enabled]) => enabled)
        .map(([feature]) => feature),
      debugMode: config.app.debugMode,
    };
  },

  /**
   * Check if running in specific environment
   * @param {string} env - Environment to check
   * @returns {boolean} Whether running in specified environment
   */
  isEnvironment(env) {
    return getConfig().app.environment === env;
  },

  /**
   * Check if feature is enabled
   * @param {string} feature - Feature name to check
   * @returns {boolean} Whether feature is enabled
   */
  isFeatureEnabled(feature) {
    return getConfig().features[feature] || false;
  },
};

// =================================================================
// SINGLETON PATTERN: Create config once and reuse
// =================================================================
let configInstance = null;

/**
 * Get application configuration (singleton pattern)
 * @returns {object} Application configuration object
 */
const getConfig = () => {
  if (!configInstance) {
    configInstance = createConfig();
    
    // Log configuration summary in development
    if (isDevelopment()) {
      console.log('🔧 Configuration loaded:', configHelpers.getSummary());
    }
  }
  
  return configInstance;
};

/**
 * Reset configuration (primarily for testing)
 * @returns {void}
 */
const resetConfig = () => {
  configInstance = null;
};

// =================================================================
// EXPORTS
// =================================================================
export {
  getConfig,
  resetConfig,
  configHelpers,
  isDevelopment,
  isProduction,
  isTest,
};

// Default export for convenience
export default getConfig;
