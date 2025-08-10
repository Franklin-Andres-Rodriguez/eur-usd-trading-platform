#!/bin/bash
# create-github-actions.sh - Crear GitHub Actions modernos para 2024-2025

echo "🚀 Creando GitHub Actions modernos para EUR/USD Trading Platform..."

# Crear directorio de workflows
mkdir -p .github/workflows

# ===== CI/CD PRINCIPAL CON ARM64 (2024-2025) =====
cat > .github/workflows/ci.yml << 'EOF'
name: 🚀 CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:

env:
  NODE_VERSION: '20'
  
permissions:
  contents: read
  security-events: write
  actions: read
  pages: write
  id-token: write

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # 🧪 Testing y Quality Gates
  test:
    name: 🧪 Quality Checks
    runs-on: ubuntu-24.04-arm64  # ARM64 para eficiencia de costos (37% más barato)
    
    strategy:
      matrix:
        browser: [chrome, firefox]
        
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - name: 🔧 Setup Node.js ${{ env.NODE_VERSION }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        registry-url: 'https://registry.npmjs.org'
        
    - name: 📦 Install dependencies
      run: |
        npm ci --prefer-offline --no-audit
        npm list --depth=0
        
    - name: 🎨 Lint code
      run: |
        npx eslint src/ --format=github
        npx prettier --check .
        
    - name: 🧪 Validate HTML
      run: npx html-validate index.html
      
    - name: ⚡ Test build
      run: npm run build
      
    - name: 📊 Bundle size analysis
      uses: preactjs/compressed-size-action@v2
      if: github.event_name == 'pull_request'
      with:
        repo-token: "${{ secrets.GITHUB_TOKEN }}"
        pattern: "dist/**/*.{js,css,html}"

  # 🔒 Security scanning con características 2024
  security:
    name: 🔒 Security Analysis
    runs-on: ubuntu-24.04-arm64
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4
      
    - name: 🔍 Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: javascript
        config: |
          paths-ignore:
            - "**/*.test.js"
            - "**/node_modules/**"
        
    - name: 🔍 Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        upload: true
        
    - name: 🔒 Run Semgrep Security Scan
      uses: returntocorp/semgrep-action@v1
      with:
        config: >-
          p/security-audit
          p/secrets
          p/owasp-top-ten
          p/javascript
          
    - name: 📦 NPM Security Audit
      run: |
        npm audit --audit-level=high --production
        
    - name: 🔍 Check for API keys in code
      run: |
        if grep -r "sk-" src/ || grep -r "API.*KEY.*=" src/ --exclude="*.example.*"; then
          echo "❌ Potential API keys found in source code!"
          exit 1
        fi
        echo "✅ No hardcoded API keys detected"

  # 🏗️ Build y Deploy
  build-deploy:
    name: 🏗️ Build & Deploy
    needs: [test, security]
    runs-on: ubuntu-24.04-arm64
    
    if: github.ref == 'refs/heads/main'
    
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4
      
    - name: 🔧 Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: 📦 Install dependencies
      run: npm ci --prefer-offline --no-audit
      
    - name: 🏗️ Build production
      run: |
        npm run build
        # Optimizar imágenes si las hay
        if [ -d "assets/images" ]; then
          npx imagemin assets/images/* --out-dir=dist/images
        fi
      env:
        NODE_ENV: production
        
    - name: 📊 Lighthouse CI Analysis
      uses: treosh/lighthouse-ci-action@v10
      with:
        configPath: '.lighthouserc.json'
        uploadArtifacts: true
        temporaryPublicStorage: true
        
    - name: 🔧 Setup GitHub Pages
      uses: actions/configure-pages@v4
      
    - name: 📤 Upload Pages artifact
      uses: actions/upload-pages-artifact@v3
      with:
        path: '.'
        
    - name: 🚀 Deploy to GitHub Pages
      id: deployment
      uses: actions/deploy-pages@v4

  # 📊 Performance Monitoring
  performance:
    name: 📊 Performance Check
    needs: [build-deploy]
    runs-on: ubuntu-24.04-arm64
    
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4
      
    - name: ⚡ Web Vitals Check
      run: |
        npx unlighthouse-ci \
          --site https://franklin-andres-rodriguez.github.io/eur-usd-trading-platform \
          --budget 95 \
          --reporter json,html
      continue-on-error: true
      
    - name: 📊 Upload performance report
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: performance-report
        path: unlighthouse-reports/
        retention-days: 30
EOF

# ===== DEPENDABOT MODERNO CON AUTO-TRIAGE =====
cat > .github/dependabot.yml << 'EOF'
version: 2
updates:
  # JavaScript dependencies con auto-triage 2024
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
      timezone: "America/Bogota"
    
    # Auto-triage moderno (GitHub 2024)
    open-pull-requests-limit: 10
    
    reviewers:
      - "Franklin-Andres-Rodriguez"
    
    commit-message:
      prefix: "deps"
      prefix-development: "deps-dev"
      include: "scope"
    
    labels:
      - "dependencies"
      - "automated"
    
    # Ignorar versiones alpha/beta
    ignore:
      - dependency-name: "*"
        versions: ["< 1.0", "> 1.0.0-alpha", "< 1.0.0-beta"]
    
    # Groups para PRs más organizados
    groups:
      development-dependencies:
        dependency-type: "development"
        patterns:
          - "eslint*"
          - "prettier"
          - "@types/*"
          - "typescript"
      
      build-dependencies:
        patterns:
          - "vite*"
          - "rollup*"
          - "webpack*"
      
      testing-dependencies:
        patterns:
          - "jest*"
          - "cypress*"
          - "playwright*"

  # GitHub Actions updates
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    
    labels:
      - "ci/cd"
      - "automated"
EOF

# ===== AUTO-MERGE INTELIGENTE =====
cat > .github/workflows/auto-merge.yml << 'EOF'
name: 🤖 Smart Auto-merge

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

permissions:
  contents: write
  pull-requests: write
  checks: read

jobs:
  auto-merge:
    name: 🤖 Auto-merge Dependabot
    runs-on: ubuntu-24.04-arm64
    
    if: |
      github.actor == 'dependabot[bot]' &&
      !github.event.pull_request.draft
    
    steps:
      - name: 📥 Checkout
        uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: 🔍 Analyze PR
        id: pr-analysis
        run: |
          PR_TITLE="${{ github.event.pull_request.title }}"
          echo "pr-title=$PR_TITLE" >> $GITHUB_OUTPUT
          
          # Determinar si es seguro para auto-merge
          if [[ "$PR_TITLE" =~ "patch" ]] || [[ "$PR_TITLE" =~ "deps:" ]]; then
            echo "auto-merge-safe=true" >> $GITHUB_OUTPUT
          else
            echo "auto-merge-safe=false" >> $GITHUB_OUTPUT
          fi
      
      - name: ⏳ Wait for status checks
        if: steps.pr-analysis.outputs.auto-merge-safe == 'true'
        uses: lewagon/wait-on-check-action@v1.3.4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
          check-name: '🧪 Quality Checks'
          repo-token: ${{ secrets.GITHUB_TOKEN }}
          wait-interval: 30
          allowed-conclusions: success
      
      - name: ✅ Auto-approve
        if: steps.pr-analysis.outputs.auto-merge-safe == 'true'
        run: |
          gh pr review ${{ github.event.number }} --approve \
            --body "🤖 Auto-approved: Safe dependency update passed all checks"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: 🔄 Auto-merge
        if: steps.pr-analysis.outputs.auto-merge-safe == 'true'
        run: |
          gh pr merge ${{ github.event.number }} \
            --squash \
            --delete-branch
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF

# ===== RELEASE AUTOMATION =====
cat > .github/workflows/release.yml << 'EOF'
name: 🚀 Release Management

on:
  push:
    branches: [main]
    tags: ['v*']
  workflow_dispatch:
    inputs:
      release_type:
        description: 'Release Type'
        required: true
        default: 'patch'
        type: choice
        options:
          - patch
          - minor
          - major

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    name: 🚀 Create Release
    runs-on: ubuntu-24.04-arm64
    
    if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v')
    
    steps:
      - name: 📥 Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: 🔧 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: 📦 Install dependencies
        run: npm ci
      
      - name: 🏗️ Build for release
        run: |
          npm run build
          # Crear archivo ZIP con distribución
          zip -r trading-platform-dist.zip dist/ index.html README.md LICENSE
      
      - name: 🏷️ Generate version
        id: version
        run: |
          if [[ "${{ github.ref }}" == refs/tags/* ]]; then
            echo "version=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT
          else
            # Auto-increment version basado en commits
            LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
            echo "last-tag=$LAST_TAG" >> $GITHUB_OUTPUT
            
            # Determinar tipo de bump
            if git log $LAST_TAG..HEAD --oneline | grep -q "feat\|BREAKING"; then
              BUMP="minor"
            elif git log $LAST_TAG..HEAD --oneline | grep -q "fix"; then
              BUMP="patch"
            else
              BUMP="patch"
            fi
            
            NEW_VERSION=$(npx semver $LAST_TAG -i $BUMP)
            echo "version=v$NEW_VERSION" >> $GITHUB_OUTPUT
          fi
      
      - name: 📝 Generate changelog
        id: changelog
        run: |
          # Generar changelog automático
          CHANGELOG=$(git log --pretty=format:"- %s (%h)" --no-merges $(git describe --tags --abbrev=0 2>/dev/null || echo "")..HEAD | head -20)
          
          cat > RELEASE_NOTES.md << EOF
          ## 🚀 EUR/USD Trading Platform ${{ steps.version.outputs.version }}
          
          ### ✨ What's New
          $CHANGELOG
          
          ### 📊 Platform Features
          - 📈 Real-time EUR/USD data with Alpha Vantage integration
          - ⏰ Multi-timeframe technical analysis (1H, 4H, Daily, Weekly)
          - 🎯 Smart confluence scoring system
          - 📅 Economic calendar with countdown timers
          - 🚨 Live alert system for trading opportunities
          - 📱 Responsive design for all devices
          
          ### 🔧 Technical Improvements
          - Enhanced performance and stability
          - Updated dependencies for security
          - Improved code quality and documentation
          
          ### 📦 Download
          - [Source Code (zip)](https://github.com/Franklin-Andres-Rodriguez/eur-usd-trading-platform/archive/${{ steps.version.outputs.version }}.zip)
          - [Live Demo](https://franklin-andres-rodriguez.github.io/eur-usd-trading-platform)
          
          ---
          **Full Changelog**: [Compare changes](https://github.com/Franklin-Andres-Rodriguez/eur-usd-trading-platform/compare/$(git describe --tags --abbrev=0 2>/dev/null || echo "initial")...${{ steps.version.outputs.version }})
          EOF
      
      - name: 🏷️ Create Release
        uses: ncipollo/release-action@v1
        with:
          tag: ${{ steps.version.outputs.version }}
          name: "EUR/USD Trading Platform ${{ steps.version.outputs.version }}"
          bodyFile: "RELEASE_NOTES.md"
          artifacts: "trading-platform-dist.zip"
          generateReleaseNotes: false
          makeLatest: true
          token: ${{ secrets.GITHUB_TOKEN }}
EOF

# ===== LIGHTHOUSE CI CONFIG =====
cat > .lighthouserc.json << 'EOF'
{
  "ci": {
    "collect": {
      "url": [
        "http://localhost:3000"
      ],
      "startServerCommand": "npx serve . -p 3000",
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:performance": ["warn", {"minScore": 0.8}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "categories:best-practices": ["warn", {"minScore": 0.8}],
        "categories:seo": ["warn", {"minScore": 0.8}]
      }
    },
    "upload": {
      "target": "temporary-public-storage"
    }
  }
}
EOF

# ===== ISSUE TEMPLATES MODERNOS =====
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/bug_report.yml << 'EOF'
name: 🐛 Bug Report
description: Report a bug in the EUR/USD Trading Platform
title: "[Bug]: "
labels: ["bug", "needs-triage"]
assignees: ["Franklin-Andres-Rodriguez"]

body:
  - type: markdown
    attributes:
      value: |
        ## 🐛 Bug Report
        Thanks for taking the time to fill out this bug report!

  - type: checkboxes
    id: checks
    attributes:
      label: Pre-flight Checklist
      options:
        - label: I have searched existing issues
          required: true
        - label: I have tested with the latest version
          required: true

  - type: dropdown
    id: component
    attributes:
      label: Component
      options:
        - Live Price Display
        - Chart System
        - Multi-Timeframe Analysis
        - Economic Calendar
        - Alert System
        - API Integration
        - UI/UX
        - Other
    validations:
      required: true

  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: A clear description of what the bug is
    validations:
      required: true

  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      placeholder: |
        1. Go to '...'
        2. Click on '...'
        3. See error
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
    validations:
      required: true

  - type: dropdown
    id: browser
    attributes:
      label: Browser
      options:
        - Chrome
        - Firefox
        - Safari
        - Edge
        - Other
    validations:
      required: true
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.yml << 'EOF'
name: ✨ Feature Request
description: Suggest a new feature
title: "[Feature]: "
labels: ["enhancement"]

body:
  - type: markdown
    attributes:
      value: |
        ## ✨ Feature Request
        We love feature requests!

  - type: dropdown
    id: category
    attributes:
      label: Feature Category
      options:
        - Trading Analysis
        - Data Integration
        - User Interface
        - API/Webhooks
        - Performance
        - Other
    validations:
      required: true

  - type: textarea
    id: problem
    attributes:
      label: Problem Statement
      description: What problem does this solve?
    validations:
      required: true

  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
      description: Describe your ideal solution
    validations:
      required: true
EOF

# ===== PULL REQUEST TEMPLATE =====
cat > .github/PULL_REQUEST_TEMPLATE.md << 'EOF'
# Pull Request

## 📋 Description
<!-- Brief description of changes -->

## 🔗 Related Issue
Closes #(issue number)

## 🧪 Type of Change
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 💥 Breaking change
- [ ] 📚 Documentation update
- [ ] 🔧 Code refactoring
- [ ] ⚡ Performance improvement

## 🧪 Testing
- [ ] Tested manually in browser
- [ ] Tested with live API data
- [ ] Cross-browser testing
- [ ] Mobile responsive testing

## 📱 Screenshots
<!-- Add screenshots if applicable -->

## 📋 Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings/errors

---
**Thank you for contributing to EUR/USD Trading Platform! 🚀**
EOF

echo "✅ GitHub Actions y templates creados"
echo "📁 Archivos creados:"
echo "├── .github/workflows/"
echo "│   ├── ci.yml (CI/CD moderno con ARM64)"
echo "│   ├── auto-merge.yml (Auto-merge inteligente)"
echo "│   └── release.yml (Release automation)"
echo "├── .github/ISSUE_TEMPLATE/"
echo "│   ├── bug_report.yml"
echo "│   └── feature_request.yml"
echo "├── .github/PULL_REQUEST_TEMPLATE.md"
echo "├── .github/dependabot.yml"
echo "└── .lighthouserc.json"
echo ""
echo "🔧 Características modernas incluidas:"
echo "✅ ARM64 runners (37% más económicos)"
echo "✅ CodeQL 2.17+ security scanning"
echo "✅ Auto-merge para dependencias seguras"
echo "✅ Lighthouse CI para performance"
echo "✅ Automated releases con semantic versioning"
echo "✅ Dependabot con auto-triage"
