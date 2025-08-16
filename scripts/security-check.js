#!/usr/bin/env node

/**
 * LOCAL SECURITY VALIDATION SCRIPT - FIXED VERSION
 * Comprehensive security check for local development
 *
 * FIXES:
 * 1. Proper npm audit error handling
 * 2. Package.json existence validation
 * 3. Better dependency validation
 * 4. Improved regex patterns for secret detection
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class SecurityValidator {
  constructor() {
    this.errors = [];
    this.warnings = [];
  }

  log(level, message) {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${level.toUpperCase()}: ${message}`);

    if (level === 'error') {
      this.errors.push(message);
    } else if (level === 'warning') {
      this.warnings.push(message);
    }
  }

  // Validate environment configuration
  validateEnvironment() {
    this.log('info', 'Validating environment configuration...');

    // Check for .env files that shouldn't be committed
    const envFiles = ['.env', '.env.local', '.env.production', '.env.staging'];
    envFiles.forEach(file => {
      if (fs.existsSync(file)) {
        this.log('error', `Environment file ${file} should not be committed to version control`);
      }
    });

    // Check for .env.example template
    if (!fs.existsSync('.env.example') && !fs.existsSync('.env.template')) {
      this.log('warning', 'Missing .env.example or .env.template file');
    }

    // Validate required environment variables in example/template
    const templateFiles = ['.env.example', '.env.template'];
    let templateFound = false;

    templateFiles.forEach(templateFile => {
      if (fs.existsSync(templateFile)) {
        templateFound = true;
        try {
          const envExample = fs.readFileSync(templateFile, 'utf8');
          const requiredVars = [
            'BROKER_API_KEY',
            'BROKER_SECRET_KEY',
            'MARKET_DATA_TOKEN',
            'JWT_SECRET',
            'NODE_ENV',
            'TRADING_ENVIRONMENT'
          ];

          requiredVars.forEach(varName => {
            if (!envExample.includes(varName)) {
              this.log('warning', `Missing ${varName} in ${templateFile}`);
            }
          });

          // Check for example values that look like real secrets
          const suspiciousPatterns = [
            /[a-zA-Z0-9]{32,}/,  // Long alphanumeric strings
            /sk_live_/,          // Stripe live keys
            /ak_live_/           // Other live API keys
          ];

          suspiciousPatterns.forEach(pattern => {
            if (pattern.test(envExample)) {
              this.log('warning', `${templateFile} may contain real credentials instead of placeholders`);
            }
          });

        } catch (err) {
          this.log('warning', `Could not read ${templateFile}: ${err.message}`);
        }
      }
    });

    if (!templateFound) {
      this.log('warning', 'No environment template file found');
    }
  }

  // Scan for hardcoded secrets with improved patterns
  scanForSecrets() {
    this.log('info', 'Scanning for hardcoded secrets...');

    const secretPatterns = [
      // Stripe API keys
      { pattern: /sk_live_[a-zA-Z0-9]{24,}/g, name: 'Stripe Live Secret Key' },
      { pattern: /pk_live_[a-zA-Z0-9]{24,}/g, name: 'Stripe Live Publishable Key' },

      // Generic API keys
      { pattern: /ak_live_[a-zA-Z0-9]{20,}/g, name: 'Live API Key' },

      // Bearer tokens
      { pattern: /bearer\s+[a-zA-Z0-9]{32,}/gi, name: 'Bearer Token' },

      // Common secret patterns (more specific to avoid false positives)
      { pattern: /password\s*[:=]\s*['"][^'"]{8,}['"]/gi, name: 'Hardcoded Password' },
      { pattern: /secret\s*[:=]\s*['"][^'"]{8,}['"]/gi, name: 'Hardcoded Secret' },
      { pattern: /password\s*[:=]\s*['"][^'"]*['"]/gi, name: 'Hardcoded Password' },
      { pattern: /secret\s*[:=]\s*['"][^'"]*['"]/gi, name: 'Hardcoded Secret' },
      { pattern: /token\s*[:=]\s*['"][^'"]*['"]/gi, name: 'Hardcoded Token' },

      // Database connection strings
      { pattern: /mongodb:\/\/[^:]+:[^@]+@/gi, name: 'MongoDB Connection String with Credentials' },
      { pattern: /mysql:\/\/[^:]+:[^@]+@/gi, name: 'MySQL Connection String with Credentials' },
      { pattern: /postgres:\/\/[^:]+:[^@]+@/gi, name: 'PostgreSQL Connection String with Credentials' },

      // Common financial API patterns
      { pattern: /broker.*key.*[:=]\s*['"][^'"]{20,}['"]/gi, name: 'Broker API Key' },
      { pattern: /trading.*secret.*[:=]\s*['"][^'"]{20,}['"]/gi, name: 'Trading Secret' },
      { pattern: /market.*data.*token.*[:=]\s*['"][^'"]{20,}['"]/gi, name: 'Market Data Token' }
    ];

    const filesToScan = this.getJSFiles('.');
    let secretsFound = false;

    filesToScan.forEach(file => {
      if (this.shouldSkipFile(file)) return;

      try {
        const content = fs.readFileSync(file, 'utf8');

        secretPatterns.forEach(({ pattern, name }) => {
          const matches = content.match(pattern);
          if (matches) {
            matches.forEach(match => {
              // Don't report secrets in comments or example files
              const lines = content.split('\n');
              let foundInComment = false;

              lines.forEach(line => {
                if (line.includes(match) && (line.trim().startsWith('//') || line.trim().startsWith('#') || line.includes('example'))) {
                  foundInComment = true;
                }
              });

              if (!foundInComment) {
                this.log('error', `${name} detected in ${file}: ${match.substring(0, 20)}...`);
                secretsFound = true;
              }
            });
          }
        });
      } catch (err) {
        this.log('warning', `Could not read file ${file}: ${err.message}`);
      }
    });

    if (!secretsFound) {
      this.log('info', '✅ No hardcoded secrets detected');
    }
  }

  // Fixed dependency validation with proper error handling
  validateDependencies() {
    this.log('info', 'Validating dependencies...');

    // First check if this is a Node.js project
    if (!fs.existsSync('package.json')) {
      this.log('warning', 'No package.json found - skipping dependency validation');
      return;
    }

    try {
      // Read package.json first to validate it's readable
      const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));

      // Check if node_modules exists
      if (!fs.existsSync('node_modules')) {
        this.log('warning', 'node_modules not found - run "npm install" first');
        return;
      }

      // Run npm audit with proper error handling
      try {
        // Use stdio: 'pipe' to capture output even on non-zero exit codes
        const auditResult = execSync('npm audit --json', {
          encoding: 'utf8',
          stdio: 'pipe',
          // Don't throw on non-zero exit codes
          maxBuffer: 1024 * 1024 // 1MB buffer for large audit outputs
        });

        const audit = JSON.parse(auditResult);

        // Check for vulnerabilities
        if (audit.metadata && audit.metadata.vulnerabilities) {
          const { critical, high, moderate, low } = audit.metadata.vulnerabilities;

          if (critical > 0 || high > 0) {
            this.log('error', `Found ${critical} critical and ${high} high severity vulnerabilities`);
          }

          if (moderate > 0) {
            this.log('warning', `Found ${moderate} moderate severity vulnerabilities`);
          }

          if (low > 0) {
            this.log('info', `Found ${low} low severity vulnerabilities`);
          }

          if (critical === 0 && high === 0 && moderate === 0 && low === 0) {
            this.log('info', '✅ No known vulnerabilities found');
          }
        }

      } catch (auditError) {
        // npm audit returns non-zero exit code when vulnerabilities are found
        // Try to parse the error output as JSON
        try {
          const audit = JSON.parse(auditError.stdout || auditError.message);
          if (audit.metadata && audit.metadata.vulnerabilities) {
            const { critical, high, moderate, low } = audit.metadata.vulnerabilities;
            if (critical > 0 || high > 0) {
              this.log('error', `Found ${critical} critical and ${high} high severity vulnerabilities`);
            }
            if (moderate > 0) {
              this.log('warning', `Found ${moderate} moderate severity vulnerabilities`);
            }
          }
        } catch (parseError) {
          this.log('warning', `npm audit failed: ${auditError.message}`);
        }
      }

      // Check for dangerous dependencies
      const dangerousDeps = [
        'eval',
        'vm2',
        'serialize-javascript',
        'node-serialize',
        'funcster'
      ];

      let dangerousFound = false;
      ['dependencies', 'devDependencies'].forEach(depType => {
        if (packageJson[depType]) {
          dangerousDeps.forEach(dep => {
            if (packageJson[depType][dep]) {
              this.log('warning', `Potentially dangerous dependency detected in ${depType}: ${dep}`);
              dangerousFound = true;
            }
          });
        }
      });

      if (!dangerousFound) {
        this.log('info', '✅ No dangerous dependencies detected');
      }

      // Check for outdated security-related packages
      const securityPackages = ['helmet', 'cors', 'express-rate-limit', 'bcrypt'];
      securityPackages.forEach(pkg => {
        if (packageJson.dependencies && !packageJson.dependencies[pkg] &&
            packageJson.dependencies['express']) {
          this.log('warning', `Consider adding security package: ${pkg}`);
        }
      });

    } catch (err) {
      this.log('warning', `Dependency validation failed: ${err.message}`);
    }
  }

  // Enhanced configuration validation
  validateConfigurations() {
    this.log('info', 'Validating configuration files...');

    // Check .gitignore
    if (!fs.existsSync('.gitignore')) {
      this.log('error', 'Missing .gitignore file - create one to prevent accidentally committing sensitive files');
    } else {
      try {
        const gitignore = fs.readFileSync('.gitignore', 'utf8');
        const criticalPatterns = [
          { pattern: '.env', description: 'Environment files' },
          { pattern: 'node_modules', description: 'Node.js dependencies' },
          { pattern: '*.log', description: 'Log files' },
          { pattern: '*secret*', description: 'Files containing secrets' },
          { pattern: '*credential*', description: 'Credential files' },
          { pattern: '*.key', description: 'Key files' }
        ];

        let missingPatterns = [];
        criticalPatterns.forEach(({ pattern, description }) => {
          if (!gitignore.includes(pattern)) {
            missingPatterns.push(`${pattern} (${description})`);
          }
        });

        if (missingPatterns.length > 0) {
          this.log('error', `Missing critical .gitignore patterns: ${missingPatterns.join(', ')}`);
        } else {
          this.log('info', '✅ .gitignore contains essential security patterns');
        }

      } catch (err) {
        this.log('warning', `Could not read .gitignore: ${err.message}`);
      }
    }

    // Check package.json security configuration
    if (fs.existsSync('package.json')) {
      try {
        const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));

        // Check for security scripts
        if (!packageJson.scripts || !packageJson.scripts.audit) {
          this.log('warning', 'Missing "audit" script in package.json - add: "audit": "npm audit"');
        }

        // Check for security-related npm scripts
        const recommendedScripts = [
          { name: 'security-check', command: 'node scripts/security-check.js' },
          { name: 'audit-fix', command: 'npm audit fix' }
        ];

        if (packageJson.scripts) {
          recommendedScripts.forEach(({ name, command }) => {
            if (!packageJson.scripts[name]) {
              this.log('info', `Consider adding script "${name}": "${command}"`);
            }
          });
        }

        // Check for engines specification
        if (!packageJson.engines) {
          this.log('warning', 'Missing "engines" field in package.json - specify Node.js version requirements');
        }

      } catch (err) {
        this.log('warning', `Could not read package.json: ${err.message}`);
      }
    }

    // Check for pre-commit hooks
    if (!fs.existsSync('.pre-commit-config.yaml') && !fs.existsSync('.husky')) {
      this.log('warning', 'No pre-commit hooks detected - consider adding pre-commit validation');
    }

    // Check for security-related configuration files
    const securityConfigs = [
      { file: '.nvmrc', description: 'Node.js version specification' },
      { file: '.npmrc', description: 'npm configuration' },
      { file: '.editorconfig', description: 'Editor configuration' }
    ];

    securityConfigs.forEach(({ file, description }) => {
      if (!fs.existsSync(file)) {
        this.log('info', `Consider adding ${file} for ${description}`);
      }
    });
  }

  // Helper methods (improved)
  getJSFiles(dir) {
    const files = [];

    try {
      const items = fs.readdirSync(dir);

      items.forEach(item => {
        const fullPath = path.join(dir, item);

        try {
          const stat = fs.statSync(fullPath);

          if (stat.isDirectory() && !this.shouldSkipDirectory(item)) {
            files.push(...this.getJSFiles(fullPath));
          } else if (stat.isFile() && this.isRelevantFile(item)) {
            files.push(fullPath);
          }
        } catch (err) {
          // Skip files we can't access
        }
      });
    } catch (err) {
      // Directory not accessible
    }

    return files;
  }

  shouldSkipDirectory(dir) {
    const skipDirs = [
      'node_modules',
      '.git',
      'dist',
      'build',
      '.next',
      'coverage',
      '.nyc_output',
      'tmp',
      'temp'
    ];
    return skipDirs.includes(dir);
  }

  shouldSkipFile(file) {
    const skipPatterns = [
      /node_modules/,
      /\.git/,
      /dist\//,
      /build\//,
      /\.min\./,
      /\.map$/,
      /coverage\//,
      /\.lock$/,
      /package-lock\.json$/
    ];

    return skipPatterns.some(pattern => pattern.test(file));
  }

  isRelevantFile(file) {
    // Expanded file types for comprehensive scanning
    return /\.(js|jsx|ts|tsx|json|md|yml|yaml|env|config)$/.test(file);
  }

  // Enhanced security report
  generateReport() {
    console.log('\n' + '='.repeat(80));
    console.log('🔐 SECURITY VALIDATION REPORT');
    console.log('='.repeat(80));

    const totalIssues = this.errors.length + this.warnings.length;

    if (totalIssues === 0) {
      console.log('✅ All security checks passed successfully!');
      console.log('🎉 Your project follows security best practices.');
    } else {
      if (this.errors.length > 0) {
        console.log(`❌ ${this.errors.length} CRITICAL SECURITY ISSUES FOUND:`);
        this.errors.forEach((error, index) => {
          console.log(`  ${index + 1}. ${error}`);
        });
        console.log('');
        console.log('🚨 CRITICAL ISSUES MUST BE FIXED BEFORE DEPLOYMENT');
      }

      if (this.warnings.length > 0) {
        console.log(`⚠️  ${this.warnings.length} Security Warnings:`);
        this.warnings.forEach((warning, index) => {
          console.log(`  ${index + 1}. ${warning}`);
        });
        console.log('');
        console.log('💡 Warnings should be addressed to improve security posture');
      }
    }

    console.log('='.repeat(80));
    console.log(`📊 Summary: ${this.errors.length} errors, ${this.warnings.length} warnings`);
    console.log(`🕒 Scan completed: ${new Date().toISOString()}`);
    console.log('='.repeat(80));

    // Exit with error code if critical issues found
    if (this.errors.length > 0) {
      console.log('');
      console.log('❌ Exiting with error code 1 due to critical security issues');
      process.exit(1);
    } else {
      console.log('');
      console.log('✅ Security validation completed successfully');
    }
  }

  // Run all validations with error handling
  run() {
    console.log('🔍 Starting comprehensive security validation...');
    console.log(`📁 Scanning directory: ${process.cwd()}`);
    console.log('');

    try {
      this.validateEnvironment();
      this.scanForSecrets();
      this.validateDependencies();
      this.validateConfigurations();
    } catch (error) {
      this.log('error', `Unexpected error during security validation: ${error.message}`);
    }

    this.generateReport();
  }
}

// Run security validation if called directly
if (require.main === module) {
  const validator = new SecurityValidator();
  validator.run();
}

module.exports = SecurityValidator;
