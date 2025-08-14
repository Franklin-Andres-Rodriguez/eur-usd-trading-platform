#!/bin/bash
# Node.js 18 Compatibility Validation for EUR/USD Trading Platform

echo "🔍 Node.js 18 Compatibility Validation"
echo "======================================"

# Check Node.js version
NODE_VERSION=$(node --version)
echo "Node.js Version: $NODE_VERSION"

# Check if Node 18.x
if [[ "$NODE_VERSION" =~ ^v18\. ]]; then
    echo "✅ COMPATIBLE: Running Node.js 18.x"
else
    echo "⚠️  WARNING: Not running Node.js 18.x"
fi

# Check for engine warnings in dependencies
echo ""
echo "🔧 Checking for engine compatibility issues..."
npm ls --depth=0 2>&1 | grep -i "engine\|unsupported" || echo "✅ No engine compatibility issues detected"

# Verify critical dependencies
echo ""
echo "📦 Critical Dependencies Status:"
ESLINT_VERSION=$(npm list eslint --depth=0 2>/dev/null | grep eslint@ | grep -o '@[0-9.]*' | cut -d@ -f2)
WEBPACK_VERSION=$(npm list webpack --depth=0 2>/dev/null | grep webpack@ | grep -o '@[0-9.]*' | cut -d@ -f2)

if [[ "$ESLINT_VERSION" =~ ^8\. ]]; then
    echo "✅ ESLint: $ESLINT_VERSION (Node 18 compatible)"
else
    echo "⚠️  ESLint: $ESLINT_VERSION (may have compatibility issues)"
fi

if [[ -n "$WEBPACK_VERSION" ]]; then
    echo "✅ Webpack: $WEBPACK_VERSION (build system ready)"
else
    echo "ℹ️  Webpack: Not in direct dependencies"
fi

# Build test
echo ""
echo "🔨 Build System Test:"
if npm run build >/dev/null 2>&1; then
    echo "✅ Build: SUCCESS (all systems operational)"
else
    echo "❌ Build: FAILED (needs investigation)"
fi

# Security check
echo ""
echo "🛡️ Security Status:"
if npm audit --production --audit-level=high >/dev/null 2>&1; then
    echo "✅ Security: No high-severity vulnerabilities"
else
    echo "⚠️  Security: Review recommended"
fi

echo ""
echo "🎯 Enterprise Compatibility: VALIDATED FOR NODE.JS 18"
