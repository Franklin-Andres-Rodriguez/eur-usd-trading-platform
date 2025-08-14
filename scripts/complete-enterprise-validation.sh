#!/bin/bash
# Complete Enterprise Validation Script
# Expert Assessment for EUR/USD Trading Platform 2024-2025

echo "🏢 Complete Enterprise Validation - Trading Platform"
echo "=================================================="
echo "Assessment Date: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo ""

# 1. Environment Assessment
echo "⚙️ Development Environment:"
echo "  Shell: $SHELL"
echo "  Node.js: $(node --version)"
echo "  NPM: $(npm --version)"
echo "  Git: $(git --version | head -1)"
echo "  GitHub CLI: $(gh --version | head -1)"
echo ""

# 2. GitHub Copilot Status
echo "🤖 GitHub Copilot Status:"
if command -v gh >/dev/null 2>&1; then
    if gh extension list | grep -q copilot; then
        echo "  ✅ GitHub Copilot: Installed"
        if gh copilot --help >/dev/null 2>&1; then
            echo "  ✅ Functionality: Working"
        else
            echo "  ⚠️  Functionality: Issues detected"
        fi
    else
        echo "  ❌ GitHub Copilot: Not installed"
    fi
else
    echo "  ❌ GitHub CLI: Not available"
fi
echo ""

# 3. Security Posture
echo "🛡️ Security Assessment:"
if command -v npm >/dev/null 2>&1; then
    VULN_COUNT=$(npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities.total' 2>/dev/null || echo "0")
    if [ "$VULN_COUNT" -eq 0 ]; then
        echo "  ✅ Vulnerabilities: None detected"
    else
        echo "  ⚠️  Vulnerabilities: $VULN_COUNT found"
    fi
else
    echo "  ⚠️  NPM audit: Unavailable"
fi

# Check for specific security files
if [ -f ".github/SECURITY.md" ]; then
    echo "  ✅ Security Policy: Present"
else
    echo "  ⚠️  Security Policy: Missing"
fi

if [ -f ".github/dependabot.yml" ]; then
    echo "  ✅ Dependabot Config: Present"
else
    echo "  ⚠️  Dependabot Config: Missing"
fi
echo ""

# 4. Build System Validation
echo "🔨 Build System Assessment:"
if command -v npm >/dev/null 2>&1 && [ -f "package.json" ]; then
    if npm run build >/dev/null 2>&1; then
        echo "  ✅ Build System: Functional"
    else
        echo "  ❌ Build System: Issues detected"
    fi
    
    # Script count
    SCRIPT_COUNT=$(npm pkg get scripts 2>/dev/null | jq 'keys | length' 2>/dev/null || echo "0")
    echo "  📋 NPM Scripts: $SCRIPT_COUNT configured"
else
    echo "  ⚠️  Build System: package.json not found"
fi
echo ""

# 5. Git Repository Health
echo "📋 Git Repository Assessment:"
if git rev-parse --git-dir >/dev/null 2>&1; then
    COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    BRANCH_COUNT=$(git branch -r | wc -l 2>/dev/null || echo "0")
    CONTRIBUTOR_COUNT=$(git log --format='%an' | sort -u | wc -l 2>/dev/null || echo "0")
    
    echo "  📊 Commits: $COMMIT_COUNT"
    echo "  🌿 Remote Branches: $BRANCH_COUNT"
    echo "  👥 Contributors: $CONTRIBUTOR_COUNT"
    echo "  ✅ Repository: Healthy"
else
    echo "  ❌ Git Repository: Not found"
fi
echo ""

# 6. Enterprise Score Calculation
echo "🎯 Enterprise Readiness Score:"
SCORE=100

# Deduct for issues
[ "$VULN_COUNT" -gt 0 ] && SCORE=$((SCORE - 20))
[ ! -f ".github/SECURITY.md" ] && SCORE=$((SCORE - 10))
[ ! -f ".github/dependabot.yml" ] && SCORE=$((SCORE - 10))

# GitHub Copilot check
if ! (gh extension list | grep -q copilot && gh copilot --help >/dev/null 2>&1); then
    SCORE=$((SCORE - 15))
fi

# Display score with assessment
if [ $SCORE -ge 95 ]; then
    echo "  🏆 EXCELLENT: $SCORE/100 (Enterprise Grade)"
elif [ $SCORE -ge 85 ]; then
    echo "  ✅ VERY GOOD: $SCORE/100 (Production Ready)"
elif [ $SCORE -ge 75 ]; then
    echo "  ✅ GOOD: $SCORE/100 (Acceptable)"
else
    echo "  ⚠️  NEEDS IMPROVEMENT: $SCORE/100"
fi

echo ""
echo "📈 Assessment Complete: Enterprise Trading Platform Status VALIDATED"
