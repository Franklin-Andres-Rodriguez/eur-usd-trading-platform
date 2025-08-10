#!/bin/bash
# verify-setup.sh - Verificación rápida del estado del proyecto

echo "🔍 EUR/USD Trading Platform - Verificación Rápida"
echo "================================================"

REPO="Franklin-Andres-Rodriguez/eur-usd-trading-platform"

echo "⭐ Stars: $(gh repo view $REPO --json stargazerCount --jq .stargazerCount)"
echo "🍴 Forks: $(gh repo view $REPO --json forkCount --jq .forkCount)"
echo "👀 Watchers: $(gh repo view $REPO --json watcherCount --jq .watcherCount)"
echo ""

echo "🐛 Issues abiertos: $(gh issue list --repo $REPO --json number | jq length)"
echo "🔄 PRs abiertos: $(gh pr list --repo $REPO --json number | jq length)"
echo ""

echo "⚡ Último workflow:"
gh run list --repo $REPO --limit 1 --json status,conclusion,workflowName | jq -r '.[0] | "   \(.workflowName): \(.status) (\(.conclusion // "running"))"' 2>/dev/null || echo "   No runs yet"

echo ""
echo "🌐 GitHub Pages:"
gh api repos/$REPO/pages --jq '.html_url' 2>/dev/null | sed 's/^/   /' || echo "   Not configured yet"

echo ""
echo "🔒 Security:"
echo "   Vulnerability alerts: $(gh api repos/$REPO/vulnerability-alerts >/dev/null 2>&1 && echo "✅" || echo "❌")"
echo "   Branch protection: $(gh api repos/$REPO/branches/main/protection >/dev/null 2>&1 && echo "✅" || echo "❌")"
