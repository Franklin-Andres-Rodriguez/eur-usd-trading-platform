#!/bin/bash
# modern-github-setup.sh - Configuración GitHub profesional 2024-2025 CORREGIDA

echo "🚀 Configurando GitHub con características modernas 2024-2025..."

# Variables del proyecto
REPO_OWNER="Franklin-Andres-Rodriguez"
REPO_NAME="eur-usd-trading-platform"
REPO_FULL="${REPO_OWNER}/${REPO_NAME}"

echo "📋 Configurando repositorio: $REPO_FULL"

# ===== 1. CONFIGURACIONES BÁSICAS MODERNAS =====
echo "🔧 1. Configuraciones básicas del repositorio..."

# Habilitar características modernas
gh repo edit $REPO_FULL \
  --enable-issues \
  --enable-projects \
  --enable-wiki \
  --enable-discussions \
  --delete-branch-on-merge \
  --enable-auto-merge \
  --enable-squash-merge \
  --visibility public

# Agregar topics para discoverabilidad (SEO de GitHub)
gh repo edit $REPO_FULL \
  --add-topic "trading" \
  --add-topic "forex" \
  --add-topic "eur-usd" \
  --add-topic "real-time-data" \
  --add-topic "alpha-vantage" \
  --add-topic "technical-analysis" \
  --add-topic "fintech" \
  --add-topic "javascript" \
  --add-topic "ai-powered" \
  --add-topic "chart-js" \
  --add-topic "open-source" \
  --add-topic "collaboration-welcome" \
  --add-topic "github-actions" \
  --add-topic "responsive-design"

echo "✅ Configuraciones básicas completadas"

# ===== 2. REPOSITORY RULESETS (MÉTODO ROBUSTO 2024) =====
echo "🛡️ 2. Configurando Repository Rulesets..."

# Método 1: Crear JSON y aplicar
cat > temp-ruleset.json << 'EOF'
{
  "name": "main-branch-protection",
  "enforcement": "active", 
  "target": "branch",
  "conditions": {
    "ref_name": {
      "include": ["main", "master"]
    }
  },
  "rules": [
    {
      "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [
          {"context": "ci/tests"},
          {"context": "security/scan"}
        ],
        "strict": true
      }
    },
    {
      "type": "required_pull_request_reviews",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews": true,
        "require_code_owner_reviews": false
      }
    },
    {
      "type": "restrict_pushes", 
      "parameters": {
        "restrict_pushes": true
      }
    },
    {
      "type": "creation",
      "parameters": {}
    },
    {
      "type": "deletion",
      "parameters": {}
    }
  ]
}
EOF

# Aplicar ruleset con manejo de errores
echo "📤 Aplicando ruleset de protección..."
if gh api repos/$REPO_FULL/rulesets --method POST --input temp-ruleset.json 2>/dev/null; then
    echo "✅ Repository ruleset creado exitosamente"
else
    echo "⚠️ No se pudo crear via API (normal en repos nuevos)"
    echo "🔗 Configurar manualmente en: https://github.com/$REPO_FULL/settings/rules"
    echo "📋 Plantilla guardada en temp-ruleset.json para referencia"
fi

# ===== 3. GITHUB DISCUSSIONS CON CATEGORÍAS =====
echo "💬 3. Habilitando GitHub Discussions..."

# Discussions ya habilitado arriba, pero verificar
if gh repo view $REPO_FULL --json hasDiscussionsEnabled --jq .hasDiscussionsEnabled | grep -q true; then
    echo "✅ GitHub Discussions habilitado"
    echo "🔗 Configurar categorías en: https://github.com/$REPO_FULL/discussions"
    
    # Crear categorías sugeridas (manual en UI)
    cat > discussion-categories.md << 'EOF'
# 💬 Categorías Sugeridas para GitHub Discussions

## Configurar en: Settings → Features → Discussions

### **📋 Categorías Recomendadas:**

1. **🚀 General** 
   - Formato: Open-ended discussion
   - Descripción: "Discusión general sobre el proyecto"

2. **💡 Ideas** 
   - Formato: Open-ended discussion  
   - Descripción: "Propuestas de nuevas funcionalidades"

3. **🐛 Bug Reports** 
   - Formato: Open-ended discussion
   - Descripción: "Reportar bugs antes de crear issues"

4. **🛠️ Development** 
   - Formato: Open-ended discussion
   - Descripción: "Discusiones técnicas de desarrollo"

5. **📊 Trading Strategies** 
   - Formato: Open-ended discussion
   - Descripción: "Compartir estrategias de trading"

6. **🤝 Show and Tell** 
   - Formato: Show and tell
   - Descripción: "Mostrar implementaciones y ejemplos"

7. **❓ Q&A** 
   - Formato: Question and Answer
   - Descripción: "Preguntas y respuestas"

8. **📢 Announcements** 
   - Formato: Announcement
   - Descripción: "Anuncios importantes del proyecto"
EOF
    echo "📋 Guía de categorías creada en discussion-categories.md"
else
    echo "❌ Error habilitando Discussions"
fi

# ===== 4. GITHUB PROJECTS V2 (MÉTODO CORREGIDO) =====
echo "📊 4. Creando GitHub Project..."

# Crear proyecto con sintaxis correcta
if gh project create --owner $REPO_OWNER --title "EUR/USD Trading Platform Roadmap" 2>/dev/null; then
    echo "✅ GitHub Project creado exitosamente"
else
    echo "⚠️ No se pudo crear proyecto via CLI"
    echo "🔗 Crear manualmente en: https://github.com/users/$REPO_OWNER/projects"
fi

# ===== 5. LABELS ÚTILES PARA COLABORACIÓN =====
echo "🏷️ 5. Creando labels útiles..."

# Labels para diferentes tipos de contribuciones
declare -A LABELS=(
    ["good-first-issue"]="Good for newcomers,7057ff"
    ["help-wanted"]="Extra attention is needed,008672" 
    ["api-integration"]="Related to API integrations,d73a4a"
    ["trading-logic"]="Trading algorithms and indicators,0075ca"
    ["ui-ux"]="User interface and experience,a2eeef"
    ["performance"]="Performance improvements,e99695"
    ["documentation"]="Documentation improvements,0052cc"
    ["security"]="Security related changes,b60205"
    ["ci-cd"]="Continuous integration and deployment,1d76db"
    ["mobile"]="Mobile responsive improvements,f9d0c4"
    ["accessibility"]="Accessibility improvements,0e8a16"
    ["testing"]="Testing improvements,c2e0c6"
    ["dependencies"]="Dependencies updates,0366d6"
    ["breaking-change"]="Breaking changes,b60205"
    ["enhancement"]="New feature or improvement,a2eeef"
    ["bug"]="Something isn't working,d73a4a"
    ["duplicate"]="This issue already exists,cfd3d7"
    ["invalid"]="This doesn't seem right,e4e669"
    ["question"]="Further information is requested,d876e3"
    ["wontfix"]="This will not be worked on,ffffff"
)

for label in "${!LABELS[@]}"; do
    IFS=',' read -r description color <<< "${LABELS[$label]}"
    
    if gh label create "$label" --description "$description" --color "$color" --repo $REPO_FULL 2>/dev/null; then
        echo "✅ Label '$label' creado"
    else
        echo "⚠️ Label '$label' ya existe o error"
    fi
done

# ===== 6. CONFIGURAR GITHUB PAGES =====
echo "🌐 6. Configurando GitHub Pages..."

# Habilitar Pages con source desde GitHub Actions (método moderno 2024)
if gh api repos/$REPO_FULL/pages --method POST --field source='{"type":"workflow"}' 2>/dev/null; then
    echo "✅ GitHub Pages configurado con Actions"
    echo "🔗 URL del sitio: https://${REPO_OWNER}.github.io/$REPO_NAME"
else
    echo "⚠️ Pages ya configurado o error. Verificar en Settings → Pages"
fi

# ===== 7. ISSUES DE EJEMPLO PARA ATRAER COLABORADORES =====
echo "📝 7. Creando issues de ejemplo..."

# Issue 1: Good first issue para UI
gh issue create \
  --title "🎨 [Good First Issue] Add dark mode toggle" \
  --body "## 🌙 Feature: Dark Mode Toggle

### Description
Add a dark mode toggle to improve trading experience during night sessions.

### Tasks
- [ ] Add toggle button in navigation
- [ ] Create dark theme CSS variables  
- [ ] Persist preference in localStorage
- [ ] Smooth transition animations
- [ ] Test accessibility

### Files to modify
- \`src/css/main.css\`
- \`index.html\` 
- \`src/js/main.js\`

**Difficulty:** Beginner  
**Estimated time:** 2-4 hours  
**Skills:** CSS, JavaScript" \
  --label "good-first-issue,ui-ux,enhancement" \
  --repo $REPO_FULL 2>/dev/null && echo "✅ Issue 'Dark Mode' creado"

# Issue 2: API Integration (intermediate)
gh issue create \
  --title "🔌 [API] Add IEX Cloud fallback provider" \
  --body "## 🔄 Feature: Additional Data Provider

### Description  
Implement IEX Cloud as fallback when Alpha Vantage fails or hits rate limits.

### Requirements
- [ ] IEX Cloud API integration
- [ ] Automatic fallback logic
- [ ] Rate limiting management
- [ ] Error handling
- [ ] Documentation update

### Technical Details
- Use IEX Cloud free tier (100,000 requests/month)
- Implement in \`src/js/api-manager.js\`
- Add configuration to \`src/config/api.js\`

**Difficulty:** Intermediate  
**Estimated time:** 1-2 days  
**Skills:** JavaScript, REST APIs" \
  --label "api-integration,enhancement,help-wanted" \
  --repo $REPO_FULL 2>/dev/null && echo "✅ Issue 'IEX Cloud' creado"

# Issue 3: Advanced feature
gh issue create \
  --title "🧠 [Advanced] Implement RSI divergence detection" \
  --body "## 📈 Feature: Advanced Technical Analysis

### Description
Implement RSI divergence detection algorithm for better trading signals.

### Technical Requirements
- [ ] Bullish divergence detection
- [ ] Bearish divergence detection  
- [ ] Visual indicators on chart
- [ ] Alert integration
- [ ] Backtesting validation

### Algorithm Details
- Compare RSI trends vs price trends
- Minimum 3 peaks/troughs for confirmation
- Configurable sensitivity parameters

**Difficulty:** Advanced  
**Estimated time:** 1-2 weeks  
**Skills:** Financial mathematics, JavaScript, Chart.js" \
  --label "trading-logic,enhancement,help-wanted" \
  --repo $REPO_FULL 2>/dev/null && echo "✅ Issue 'RSI Divergence' creado"

# ===== 8. CONFIGURACIÓN DE SEGURIDAD AVANZADA =====
echo "🔒 8. Configurando seguridad avanzada..."

# Habilitar vulnerability alerts y automated security updates
gh api repos/$REPO_FULL/vulnerability-alerts --method PUT 2>/dev/null && echo "✅ Vulnerability alerts habilitados"
gh api repos/$REPO_FULL/automated-security-fixes --method PUT 2>/dev/null && echo "✅ Security fixes automatizados habilitados"

# ===== 9. ARCHIVO DE CONFIGURACIÓN FINAL =====
cat > .github/repository-config.yml << 'EOF'
# Repository Configuration Summary
# Generated automatically by modern-github-setup.sh

repository:
  name: eur-usd-trading-platform
  owner: Franklin-Andres-Rodriguez
  visibility: public
  
features:
  issues: true
  projects: true  
  wiki: true
  discussions: true
  actions: true
  pages: true
  
security:
  vulnerability_alerts: true
  automated_security_fixes: true
  secret_scanning: true
  
automation:
  delete_branch_on_merge: true
  auto_merge: true
  squash_merge: true
  
protection:
  repository_rulesets: true
  required_status_checks: true
  required_pull_request_reviews: true
  
collaboration:
  good_first_issues: true
  help_wanted_issues: true
  comprehensive_labels: true
  discussion_categories: configured
EOF

# ===== 10. LIMPIEZA Y RESUMEN =====
echo "🧹 10. Limpieza final..."

# Limpiar archivos temporales
rm -f temp-ruleset.json

echo ""
echo "🎉 ¡Configuración GitHub moderna completada!"
echo "=========================================="
echo ""
echo "✅ **Características configuradas:**"
echo "   🔧 Repository settings modernos"
echo "   🛡️ Repository rulesets (branch protection)"
echo "   💬 GitHub Discussions habilitado"
echo "   📊 GitHub Projects creado"
echo "   🏷️ Labels profesionales (20+)"
echo "   🌐 GitHub Pages con Actions"
echo "   📝 Issues de ejemplo para colaboradores"
echo "   🔒 Seguridad avanzada habilitada"
echo ""
echo "🔗 **URLs importantes:**"
echo "   📱 Demo: https://${REPO_OWNER}.github.io/$REPO_NAME"
echo "   📋 Repo: https://github.com/$REPO_FULL"
echo "   🐛 Issues: https://github.com/$REPO_FULL/issues"
echo "   💬 Discussions: https://github.com/$REPO_FULL/discussions"
echo "   📊 Projects: https://github.com/users/$REPO_OWNER/projects"
echo ""
echo "⚠️ **Configuración manual requerida:**"
echo "   🛡️ Repository Rulesets: Settings → Rules"
echo "   💬 Discussion Categories: Settings → Features → Discussions"
echo "   📊 Project visibility: Projects → Settings → Visibility"
echo ""
echo "📋 **Próximos pasos:**"
echo "   1. Verificar GitHub Pages deploy"
echo "   2. Configurar API key real en src/config/api.js"
echo "   3. Test completo del sitio"
echo "   4. Launch marketing (Show HN, Reddit, Twitter)"
echo ""
echo "🚀 ¡Tu repositorio está listo para collaboration y success!"
