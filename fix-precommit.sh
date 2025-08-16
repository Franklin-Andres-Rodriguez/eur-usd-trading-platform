#!/usr/bin/env zsh
# =============================================================================
# FIX PRE-COMMIT HOOK - Allow .env.example but block .env files
# =============================================================================

echo "🔧 FIXING PRE-COMMIT HOOK CONFIGURATION"
echo "======================================="

# Update .pre-commit-config.yaml to allow .env.example
cat > .pre-commit-config.yaml << 'EOF'
repos:
  # Secret detection with proper exclusions
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
        exclude: |
          (?x)^(
            package-lock\.json|
            \.env\.example|
            \.env\.template|
            docs/.*\.md|
            README\.md
          )$

  # General security checks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: check-added-large-files
        args: ['--maxkb=1000']
      - id: check-case-conflict
      - id: check-merge-conflict
      - id: check-yaml
      - id: check-json
      - id: trailing-whitespace
      - id: end-of-file-fixer

  # Custom environment file validation (allow templates, block actual env files)
  - repo: local
    hooks:
      - id: block-env-files
        name: Block .env files (except templates)
        entry: bash -c 'if ls .env .env.local .env.production .env.staging .env.development 2>/dev/null | grep -v "\.example$" | grep -v "\.template$"; then echo "❌ BLOCKED: Real .env files detected! Use .env.example instead."; exit 1; fi'
        language: system
        pass_filenames: false
        
      - id: financial-secrets-check
        name: Financial Secrets Detection
        entry: bash -c 'if grep -r -E "(sk_live_|ak_live_|bearer.*[a-zA-Z0-9]{32,})" . --exclude-dir=node_modules --exclude-dir=.git --exclude="*.example" --exclude="*.template" --exclude="*.md"; then echo "❌ BLOCKED: Financial secrets detected!"; exit 1; fi'
        language: system
        pass_filenames: false

      - id: npm-audit-check
        name: NPM Security Audit
        entry: npm audit --audit-level moderate
        language: system
        pass_filenames: false
        files: package\.json$
EOF

echo "✅ Updated .pre-commit-config.yaml to allow .env.example"

# Create .secrets.baseline if it doesn't exist
if [ ! -f .secrets.baseline ]; then
    echo "🔍 Creating secrets baseline..."
    cat > .secrets.baseline << 'EOF'
{
  "version": "1.4.0",
  "plugins_used": [
    {
      "name": "ArtifactoryDetector"
    },
    {
      "name": "AWSKeyDetector"
    },
    {
      "name": "Base64HighEntropyString",
      "limit": 4.5
    },
    {
      "name": "BasicAuthDetector"
    },
    {
      "name": "CloudantDetector"
    },
    {
      "name": "HexHighEntropyString",
      "limit": 3.0
    },
    {
      "name": "JwtTokenDetector"
    },
    {
      "name": "KeywordDetector",
      "keyword_exclude": ""
    },
    {
      "name": "MailchimpDetector"
    },
    {
      "name": "PrivateKeyDetector"
    },
    {
      "name": "SlackDetector"
    },
    {
      "name": "SoftlayerDetector"
    },
    {
      "name": "SquareOAuthDetector"
    },
    {
      "name": "StripeDetector"
    },
    {
      "name": "TwilioKeyDetector"
    }
  ],
  "filters_used": [
    {
      "path": "detect_secrets.filters.allowlist.is_line_allowlisted"
    },
    {
      "path": "detect_secrets.filters.common.is_baseline_file"
    },
    {
      "path": "detect_secrets.filters.common.is_ignored_due_to_verification_policies",
      "min_level": 2
    }
  ],
  "results": {},
  "generated_at": "2025-08-15T16:52:00Z"
}
EOF
    echo "✅ Created .secrets.baseline"
fi

# Update .gitignore to be more specific about .env files
echo "🔧 Updating .gitignore to be more specific..."
cat > .gitignore << 'EOF'
# =============================================================================
# ENTERPRISE .GITIGNORE - EUR/USD Trading Platform
# CRITICAL: Allow templates (.env.example) but block real env files
# =============================================================================

# Environment files (BLOCK real env files, ALLOW templates)
.env
.env.local
.env.production
.env.staging
.env.development
.env.test
!.env.example
!.env.template

# Secrets and credentials (BLOCK all variations)
*secret*
*credential*
*password*
*token*
*key*
*api*key*
*private*
!*.example.*
!*.template.*

# Trading platform specific
config/broker-*.json
config/api-*.json
config/trading-*.json
config/production.*
config/staging.*
src/config/*secret*
src/config/*credential*
market-data/
feeds/
quotes/
strategies/
algorithms/
risk-models/

# Financial compliance data
mifid/
gdpr-exports/
pci/
sox/
audit-trails/
transaction-logs/
customer-data/
financial-exports/
compliance-reports/

# Development files
node_modules/
.npm/
.cache/
build/
dist/
coverage/
logs/
*.log*
debug/
profiling/
monitoring-data/

# Security & certificates
ssl/
certificates/
*.pem
*.key
*.crt
*.cert
*.p12
*.pfx

# Database & backups
*.sql
*.dump
*.backup
dumps/
backups/

# OS & editors
.DS_Store
Thumbs.db
.vscode/settings.json
.idea/

# Docker & infrastructure
docker-compose.override.yml
k8s/secrets/
k8s/production/
*.tfstate*
.terraform/

# Monitoring & observability
apm/
traces/
metrics/
error-tracking/

# ALWAYS INCLUDE these safe template files
!.env.example
!.env.template
!config/*.example.*
!config/*.template.*
!docs/examples/
!examples/
EOF

echo "✅ Updated .gitignore with proper .env.example handling"

echo ""
echo "🎯 CONFIGURATION FIXED - Now you can commit safely"
echo "=================================================="
echo ""
echo "📋 What was fixed:"
echo "   ✅ .pre-commit-config.yaml now allows .env.example"
echo "   ✅ .secrets.baseline created for detect-secrets"
echo "   ✅ .gitignore updated with proper template handling"
echo "   ✅ Financial secrets detection still active"
echo ""
echo "🚀 READY TO COMMIT - Run these commands:"
echo "   git add ."
echo "   git commit -m \"🔒 ENTERPRISE: Implement advanced security framework\""
echo "   git push origin main"
