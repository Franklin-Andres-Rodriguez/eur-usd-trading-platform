#!/usr/bin/env node
/**
 * Enterprise Security Scanner
 * Comprehensive security validation for EUR/USD Trading Platform
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

class EnterpriseSecurityScanner {
  constructor() {
    this.vulnerabilities = [];
    this.warnings = [];
    this.scanResults = {
      secrets: { found: 0, patterns: [] },
      files: { scanned: 0, suspicious: 0 },
      config: { valid: true, issues: [] }
    };
  }

  scan() {
    console.log('🔍 Enterprise Security Scanner v2.1.0');
    console.log('=====================================');
    
    this.scanForSecrets();
    this.scanFilePermissions();
    this.validateConfigurations();
    this.generateReport();
    
    return this.vulnerabilities.length === 0;
  }

  scanForSecrets() {
    console.log('\n🕵️  Scanning for hardcoded secrets...');
    
    const patterns = [
      { name: 'Live Broker API Key', regex: /sk_live_[a-zA-Z0-9]{20,}/g },
      { name: 'Live API Key', regex: /ak_live_[a-zA-Z0-9]{20,}/g },
      { name: 'Bearer Token', regex: /bearer\s+[a-zA-Z0-9]{32,}/gi },
      { name: 'JWT Secret', regex: /jwt[_-]?secret['":\s]*[a-zA-Z0-9]{16,}/gi },
      { name: 'Database URL', regex: /mongodb:\/\/[^'\s"]+/gi },
      { name: 'Live Broker API Key', regex: /sk_live_[a-zA-Z0-9]{20,}/ },
      { name: 'Live API Key', regex: /ak_live_[a-zA-Z0-9]{20,}/ },
      { name: 'Bearer Token', regex: /bearer\s+[a-zA-Z0-9]{32,}/i },
      { name: 'JWT Secret', regex: /jwt[_-]?secret['":\s]*[a-zA-Z0-9]{16,}/i },
      { name: 'Database URL', regex: /mongodb:\/\/[^'\s"]+/i },
      { name: 'Private Key', regex: /-----BEGIN[A-Z\s]+PRIVATE KEY-----/i }
    ];

    this.scanDirectory('.', patterns);
    
    if (this.scanResults.secrets.found > 0) {
      console.log(`❌ Found ${this.scanResults.secrets.found} potential secrets`);
    } else {
      console.log('✅ No secrets detected');
    }
  }

  scanDirectory(dir, patterns) {
    const files = fs.readdirSync(dir, { withFileTypes: true });
    
    files.forEach(file => {
      const fullPath = path.join(dir, file.name);
      
      if (file.isDirectory() && !this.shouldSkipDirectory(file.name)) {
        this.scanDirectory(fullPath, patterns);
      } else if (file.isFile() && this.shouldScanFile(file.name)) {
        this.scanFile(fullPath, patterns);
      }
    });
  }

  scanFile(filePath, patterns) {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      this.scanResults.files.scanned++;
      
      patterns.forEach(pattern => {
        const matches = content.match(pattern.regex);
        if (matches) {
          this.vulnerabilities.push({
            type: 'SECRET_DETECTED',
            file: filePath,
            pattern: pattern.name,
            matches: matches.length,
            severity: 'CRITICAL'
          });
          this.scanResults.secrets.found += matches.length;
          this.scanResults.secrets.patterns.push(pattern.name);
        }
      });
    } catch (err) {
      this.warnings.push(`Could not scan file: ${filePath}`);
    }
  }

  validateConfigurations() {
    console.log('\n⚙️  Validating security configurations...');
    
    // Check .gitignore
    if (!fs.existsSync('.gitignore')) {
      this.vulnerabilities.push({
        type: 'MISSING_GITIGNORE',
        severity: 'HIGH',
        message: '.gitignore file missing'
      });
    }
    
    // Check environment template
    if (!fs.existsSync('.env.example')) {
      this.warnings.push('Missing .env.example template');
    }
    
    // Validate package.json security
    if (fs.existsSync('package.json')) {
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      
      if (!pkg.scripts || !pkg.scripts['security:audit']) {
        this.warnings.push('Missing security:audit script in package.json');
      }
    }
    
    console.log('✅ Configuration validation completed');
  }

  generateReport() {
    console.log('\n📊 SECURITY SCAN REPORT');
    console.log('=======================');
    console.log(`Files Scanned: ${this.scanResults.files.scanned}`);
    console.log(`Vulnerabilities: ${this.vulnerabilities.length}`);
    console.log(`Warnings: ${this.warnings.length}`);
    
    if (this.vulnerabilities.length > 0) {
      console.log('\n🚨 CRITICAL VULNERABILITIES:');
      this.vulnerabilities.forEach((vuln, index) => {
        console.log(`${index + 1}. ${vuln.type} - ${vuln.severity}`);
        if (vuln.file) console.log(`   File: ${vuln.file}`);
        if (vuln.message) console.log(`   Message: ${vuln.message}`);
      });
    }
    
    if (this.warnings.length > 0) {
      console.log('\n⚠️  WARNINGS:');
      this.warnings.forEach((warning, index) => {
        console.log(`${index + 1}. ${warning}`);
      });
    }
    
    const status = this.vulnerabilities.length === 0 ? 'PASSED' : 'FAILED';
    console.log(`\n🎯 SECURITY STATUS: ${status}`);
  }

  shouldSkipDirectory(dir) {
    const skipDirs = ['node_modules', '.git', 'dist', 'build', '.next'];
    return skipDirs.includes(dir);
  }

  shouldScanFile(file) {
    return /\.(js|jsx|ts|tsx|json|md|txt|yml|yaml)$/.test(file);
  }
}

// Run scanner if called directly
if (require.main === module) {
  const scanner = new EnterpriseSecurityScanner();
  const passed = scanner.scan();
  process.exit(passed ? 0 : 1);
}

module.exports = EnterpriseSecurityScanner;
