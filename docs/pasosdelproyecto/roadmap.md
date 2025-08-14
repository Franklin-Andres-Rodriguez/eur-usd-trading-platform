# EUR/USD Trading Platform - Roadmap Detallado Integrado

## 📊 **Resumen de Fases y Métricas (ACTUALIZADO)**

| Fase | Duración | Tareas Principales | Subtareas Originales | Subtareas Agregadas | Total Subtareas | Criterio de Éxito |
|------|----------|-------------------|---------------------|-------------------|----------------|------------------|
| **Fase 0** | 1 semana | 4 tareas | 16 subtareas | +2 subtareas | 18 subtareas | Base sólida + bundling |
| **Fase 1** | 4-6 semanas | 6 tareas | 28 subtareas | +4 subtareas | 32 subtareas | Documentación + Testing + Security mejorada |
| **Fase 2** | 6-8 semanas | 5 tareas | 22 subtareas | +5 subtareas | 27 subtareas | Escalabilidad + PWA + Resilience |
| **Fase 3** | 8-10 semanas | 4 tareas | 18 subtareas | +2 subtareas | 20 subtareas | Features avanzadas + ML optimizado |
| **Fase 4** | 10-12 semanas | 3 tareas | 15 subtareas | +1 subtarea | 16 subtareas | Enterprise ready + Auth |

**Total: ~32.5 semanas, 22 tareas principales, 113 subtareas**

---

## 🚀 **FASE 0: Setup Inmediato** 
*Duración: 4-5 días | Prioridad: ALTA*

**Objetivo:** Completar fundamentos para desarrollo productivo + bundling moderno
**Estado Actual: ✅ 5/18 subtareas completadas (28%)**

### **Tarea 0.1: Repository Setup y Standards** ⏱️ 1 día restante
- [x] **0.1.1** ✅ Crear `.gitignore` comprehensivo - *Tu package.json indica que ya tienes esto*
- [x] **0.1.2** Configurar `.editorconfig` para consistencia de código
- [x] **0.1.3** ✅ Setup de ESLint + Prettier - *Configurado en devDependencies*
- [x] **0.1.4** Crear template de Pull Request y Issue templates

### **Tarea 0.2: Documentación Básica** ⏱️ 1.5 días restantes
- [x] **0.2.1** Crear README.md detallado con quick start y badges
- [x] **0.2.2** Documentar estructura de carpetas actual
- [x] **0.2.3** Crear CONTRIBUTING.md con guidelines de desarrollo
- [x] **0.2.4** ✅ Setup de GitHub Pages - *GITHUB_PAGES_SETUP.md excelente*

### **Tarea 0.3: Development Environment** ⏱️ 1 día restante
- [x] **0.3.1** ✅ Configurar package.json - *EXCELENTE cobertura de scripts*
- [x] **0.3.2** ✅ Setup de ambiente local - *live-server configurado perfectamente*
- [x] **0.3.3** Configurar variables de entorno (.env setup y .env.example)
- [x] **0.3.4** Documentar prerequisitos y setup process
- [x] **0.3.5** 🆕 **INTEGRACIÓN:** Configurar Webpack básico para bundling
- [x] **0.3.6** 🆕 **INTEGRACIÓN:** Setup de source maps para debugging

### **Tarea 0.4: Initial Security Audit** ⏱️ 1 día
- [x] **0.4.1** Audit de API key management actual (revisar src/config/api.js)
- [x] **0.4.2** Identificar vulnerabilidades básicas con npm audit
- [x] **0.4.3** Implementar HTTPS enforcement y security headers
- [x] **0.4.4** Crear security.md con reportes de vulnerabilidades

**Criterio de Completitud Fase 0:** ✅ 18/18 subtareas • Development environment funcional • Bundling moderno • Security baseline • Source maps habilitados

---

## 📋 **FASE 1: Fundamentación Técnica**
*Duración: 4-6 semanas | Prioridad: ALTA*

**Objetivo:** Documentación comprehensiva, testing framework avanzado, y arquitectura sólida con mejoras de seguridad

### **Tarea 1.1: Documentación Arquitectural** ⏱️ 8 días
- [ ] **1.1.1** System Architecture Document con diagramas Mermaid
- [ ] **1.1.2** API Specification (Alpha Vantage integration)
- [ ] **1.1.3** Data Flow Diagrams (market data → UI)
- [ ] **1.1.4** Component Interaction Documentation
- [ ] **1.1.5** Database Schema Documentation (si aplica)
- [ ] **1.1.6** External Dependencies Mapping

### **Tarea 1.2: Testing Framework Implementation** ⏱️ 12 días
- [ ] **1.2.1** Setup Jest para unit testing
- [ ] **1.2.2** Setup Cypress para E2E testing  
- [ ] **1.2.3** Crear primeros 10 unit tests (utils, calculations)
- [ ] **1.2.4** Implementar test coverage reporting
- [ ] **1.2.5** Setup de mocking para API calls
- [ ] **1.2.6** Crear E2E tests para user flows críticos
- [ ] **1.2.7** Configurar test automation en CI/CD
- [ ] **1.2.8** 🆕 **INTEGRACIÓN:** Setup de DOM Testing Library para Vanilla JS
- [ ] **1.2.9** 🆕 **INTEGRACIÓN:** Configurar Visual Regression Testing (Percy/Chromatic)

### **Tarea 1.3: Code Quality Systems** ⏱️ 5 días
- [ ] **1.3.1** Configurar SonarQube/CodeClimate
- [ ] **1.3.2** Setup de pre-commit hooks (Husky)
- [ ] **1.3.3** Implementar code review guidelines
- [ ] **1.3.4** Configurar Lighthouse CI para performance
- [ ] **1.3.5** Setup de dependency vulnerability scanning

### **Tarea 1.4: Security Implementation** ⏱️ 8 días
- [ ] **1.4.1** Implementar secure API key management
- [ ] **1.4.2** Input validation y sanitization
- [ ] **1.4.3** Rate limiting implementation
- [ ] **1.4.4** CORS configuration apropiada
- [ ] **1.4.5** Security headers implementation
- [ ] **1.4.6** Error handling que no exponga información
- [ ] **1.4.7** 🆕 **INTEGRACIÓN:** Implementar Content Security Policy (CSP) headers
- [ ] **1.4.8** 🆕 **INTEGRACIÓN:** Setup de Subresource Integrity (SRI) para CDNs

### **Tarea 1.5: Performance Baseline** ⏱️ 4 días
- [ ] **1.5.1** Establecer métricas de performance actuales
- [ ] **1.5.2** Optimizar bundle size (webpack/rollup)
- [ ] **1.5.3** Implementar lazy loading para components
- [ ] **1.5.4** Setup de monitoring básico

### **Tarea 1.6: CI/CD Pipeline** ⏱️ 3 días
- [ ] **1.6.1** GitHub Actions para testing automatizado
- [ ] **1.6.2** Automated deployment a staging
- [ ] **1.6.3** Automated deployment a production (GitHub Pages)
- [ ] **1.6.4** Setup de notifications (Discord/Slack)

**Criterio de Completitud Fase 1:** ✅ 32/32 subtareas • Code coverage >80% • Documentación técnica completa • Security audit pasado • CI/CD funcional • DOM testing setup • CSP headers implementados

---

## ⚡ **FASE 2: Escalabilidad y Performance**
*Duración: 6-8 semanas | Prioridad: MEDIA-ALTA*

**Objetivo:** Preparar plataforma para crecimiento, optimizar experiencia de usuario, y añadir resilience patterns

### **Tarea 2.1: Real-Time Data Architecture** ⏱️ 14 días
- [ ] **2.1.1** Implementar WebSocket connection manager
- [ ] **2.1.2** Event-driven architecture implementation
- [ ] **2.1.3** Real-time price updates sistema
- [ ] **2.1.4** Connection recovery y reconnection logic
- [ ] **2.1.5** Rate limiting para real-time data
- [ ] **2.1.5.1** 🆕 **INTEGRACIÓN:** Implementar Exponential Backoff para reconnections
- [ ] **2.1.5.2** 🆕 **INTEGRACIÓN:** Circuit Breaker pattern para API calls
- [ ] **2.1.6** Offline-first data strategy

### **Tarea 2.2: State Management Refactor** ⏱️ 10 días
- [ ] **2.2.1** Implementar Redux/Zustand para state global
- [ ] **2.2.2** Migrar component state a store centralizado
- [ ] **2.2.3** Implementar middleware para debugging
- [ ] **2.2.4** Setup de persistence para user preferences
- [ ] **2.2.5** Action creators y reducers para trading data

### **Tarea 2.3: Component Library Creation** ⏱️ 8 días
- [ ] **2.3.1** Crear design system básico
- [ ] **2.3.2** Componentizar UI elements repetitivos
- [ ] **2.3.3** Setup de Storybook para documentation
- [ ] **2.3.4** Implementar theming system (light/dark mode)

### **Tarea 2.4: Progressive Web App Features** ⏱️ 10 días
- [ ] **2.4.1** Service Worker implementation
- [ ] **2.4.2** Offline functionality para historical data
- [ ] **2.4.3** Push notifications para alerts
- [ ] **2.4.4** App manifest y installability
- [ ] **2.4.5** 🆕 **INTEGRACIÓN:** Background Sync para datos críticos
- [ ] **2.4.6** 🆕 **INTEGRACIÓN:** Web App Shortcuts para quick actions
- [ ] **2.4.7** 🆕 **INTEGRACIÓN:** Implementar app install prompts inteligentes

### **Tarea 2.5: Advanced Testing Strategy** ⏱️ 6 días
- [ ] **2.5.1** Performance testing con Lighthouse CI
- [ ] **2.5.2** Load testing para API endpoints
- [ ] **2.5.3** Visual regression testing
- [ ] **2.5.4** Accessibility testing (axe-core)

**Criterio de Completitud Fase 2:** ✅ 27/27 subtareas • PWA score >90 • Performance Lighthouse >90 • Real-time data funcional • Component library documentada • Resilience patterns implementados • Background sync funcional

---

## 🚀 **FASE 3: Features Avanzadas**
*Duración: 8-10 semanas | Prioridad: MEDIA*

**Objetivo:** Diferenciación competitiva, funcionalidades premium, y ML optimizado para Vanilla JS

### **Tarea 3.1: Machine Learning Integration** ⏱️ 17 días
- [ ] **3.1.1** Research e implementación de TensorFlow.js
- [ ] **3.1.2** Modelo predictivo básico para trend analysis
- [ ] **3.1.3** Training pipeline para historical data
- [ ] **3.1.4** UI para ML predictions y confidence scores
- [ ] **3.1.4.1** 🆕 **INTEGRACIÓN:** Implementar Web Workers para ML processing
- [ ] **3.1.4.2** 🆕 **INTEGRACIÓN:** Setup de modelo offline-first con IndexedDB
- [ ] **3.1.5** A/B testing para ML vs traditional analysis

### **Tarea 3.2: Advanced Charting System** ⏱️ 12 días
- [ ] **3.2.1** Migración a D3.js para charts personalizados
- [ ] **3.2.2** Custom technical indicators implementation
- [ ] **3.2.3** Interactive chart annotations
- [ ] **3.2.4** Multi-chart synchronization
- [ ] **3.2.5** Chart export functionality (PNG, PDF)
- [ ] **3.2.6** Custom timeframe selections

### **Tarea 3.3: Portfolio Management Features** ⏱️ 10 días
- [ ] **3.3.1** Portfolio tracking implementation
- [ ] **3.3.2** Risk calculation algorithms
- [ ] **3.3.3** Portfolio optimization suggestions
- [ ] **3.3.4** Historical portfolio performance

### **Tarea 3.4: Social Trading Features** ⏱️ 8 días
- [ ] **3.4.1** User profiles y trading statistics
- [ ] **3.4.2** Signal sharing functionality
- [ ] **3.4.3** Leaderboard implementation
- [ ] **3.4.4** Social feed para trading ideas

**Criterio de Completitud Fase 3:** ✅ 20/20 subtareas • ML predictions funcional • Advanced charts implementados • Portfolio management básico • Social features MVP • ML processing no bloquea UI • Offline ML models funcionando

---

## 🏢 **FASE 4: Enterprise Features** 
*Duración: 10-12 semanas | Prioridad: BAJA*

**Objetivo:** Preparación para escala enterprise, monetización, y autenticación sin backend

### **Tarea 4.1: Multi-User Support** ⏱️ 16 días
- [ ] **4.1.1** User authentication system
- [ ] **4.1.2** Role-based access control
- [ ] **4.1.3** User dashboard personalizable
- [ ] **4.1.4** Multi-tenant architecture
- [ ] **4.1.5** User analytics y tracking
- [ ] **4.1.6** 🆕 **INTEGRACIÓN:** Implementar session management sin backend (JWT + localStorage)

### **Tarea 4.2: API Marketplace Integration** ⏱️ 12 días
- [ ] **4.2.1** Multiple data provider support
- [ ] **4.2.2** Provider switching functionality
- [ ] **4.2.3** Data quality comparison tools
- [ ] **4.2.4** Cost optimization algorithms

### **Tarea 4.3: Advanced Analytics Dashboard** ⏱️ 8 días
- [ ] **4.3.1** Business intelligence dashboard
- [ ] **4.3.2** Custom report generation
- [ ] **4.3.3** Data export capabilities
- [ ] **4.3.4** Automated report scheduling

**Criterio de Completitud Fase 4:** ✅ 16/16 subtareas • Multi-user funcional • Enterprise dashboard • API marketplace integration • Advanced analytics • Session management sin backend funcional

---

## 🎯 **Sistema de Tracking y Métricas (ACTUALIZADO)**

### **Métricas de Progreso por Fase**

```javascript
// Sistema de tracking recomendado
const projectMetrics = {
  phase0: {
    totalTasks: 4,
    totalSubtasks: 18,
    completed: 5,
    progressPercentage: 28,
    estimatedDays: 5,
    actualDays: 0
  },
  phase1: {
    totalTasks: 6,
    totalSubtasks: 32,
    completed: 0,
    progressPercentage: 0,
    estimatedDays: 40,
    actualDays: 0
  },
  phase2: {
    totalTasks: 5,
    totalSubtasks: 27,
    completed: 0,
    progressPercentage: 0,
    estimatedDays: 48,
    actualDays: 0
  },
  phase3: {
    totalTasks: 4,
    totalSubtasks: 20,
    completed: 0,
    progressPercentage: 0,
    estimatedDays: 62,
    actualDays: 0
  },
  phase4: {
    totalTasks: 3,
    totalSubtasks: 16,
    completed: 0,
    progressPercentage: 0,
    estimatedDays: 36,
    actualDays: 0
  }
};

// KPIs Técnicos por Fase (ACTUALIZADOS)
const technicalKPIs = {
  phase0: {
    webpackBuild: "Funcional",
    sourceMaps: "Habilitados", 
    securityBaseline: "Establecido"
  },
  phase1: {
    codeRoverage: ">80%",
    lighthouseScore: ">85",
    securityScan: "Pass",
    documentation: "100%",
    domTesting: "Configurado",
    cspHeaders: "Implementados"
  },
  phase2: {
    pwaScore: ">90",
    performanceScore: ">90",
    realTimeLatency: "<50ms",
    resiliencePatterns: "Implementados",
    backgroundSync: "Funcional"
  },
  phase3: {
    mlAccuracy: ">65%",
    mlInference: "<100ms",
    uiBlocking: "Ninguno",
    offlineML: "Funcional"
  },
  phase4: {
    multiUser: "Funcional",
    sessionManagement: "Sin backend",
    enterpriseDashboard: "Implementado"
  }
};
```

### **Herramientas de Tracking Recomendadas**

**Para Tareas:**
- GitHub Projects para kanban board
- GitHub Issues para tracking individual
- GitHub Milestones para fases

**Para Métricas:**
- Codecov para coverage tracking
- Lighthouse CI para performance
- SonarQube para code quality
- GitHub Actions para automation

**Para Integraciones Nuevas:**
- Webpack Bundle Analyzer para bundle optimization
- Percy/Chromatic para visual regression
- Web Workers performance monitoring
- CSP violation reporting

### **Reporting Weekly (ACTUALIZADO)**

```markdown
## Weekly Progress Report

### Fase Actual: [FASE_X]
- **Progreso General:** XX/XX subtareas (XX%)
- **Subtareas Originales:** XX/XX completadas
- **Integraciones Técnicas:** XX/XX completadas  
- **Blockers:** [Lista de impedimentos]
- **Próxima Semana:** [3-5 subtareas específicas]
- **Métricas Técnicas:** 
  - Code Coverage: XX%
  - Lighthouse Score: XX
  - Security Issues: XX
  - Bundle Size: XX KB
  - Performance: XX ms

### Integraciones Implementadas:
- [Integración 1]: Estado/Beneficio
- [Integración 2]: Estado/Beneficio

### Riesgos Identificados:
- [Riesgo 1]: Impacto/Probabilidad/Mitigación
- [Riesgo 2]: Impacto/Probabilidad/Mitigación
```

---

## 🚨 **Criterios de Definition of Done (ACTUALIZADOS)**

### **Para cada Subtarea:**
- [ ] Código implementado y testeado
- [ ] Code review completado y aprobado
- [ ] Documentación actualizada
- [ ] Tests unitarios pasando
- [ ] No hay regresiones en E2E tests
- [ ] (**Si es integración**) Métricas específicas cumplidas

### **Para cada Tarea Principal:**
- [ ] Todas las subtareas completadas (originales + integraciones)
- [ ] Integration tests pasando
- [ ] Performance benchmarks cumplidos
- [ ] Security scan sin vulnerabilidades críticas
- [ ] Documentación de usuario actualizada
- [ ] Integraciones específicas validadas

### **Para cada Fase:**
- [ ] Todas las tareas principales completadas
- [ ] Criterios de completitud específicos cumplidos
- [ ] Integraciones técnicas funcionando correctamente
- [ ] Stakeholder approval obtenido
- [ ] Deployment exitoso a staging
- [ ] Retrospectiva de fase completada

---

## 🔧 **Detalles de Implementación de Integraciones**

### **Fase 0 - Integraciones Específicas**

#### **0.3.5: Webpack Básico**
```javascript
// webpack.config.js
const path = require('path');

module.exports = {
  entry: './src/js/main.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.[contenthash].js',
    clean: true,
  },
  mode: 'production',
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          chunks: 'all',
        },
      },
    },
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
};
```

#### **0.3.6: Source Maps**
```json
// package.json update
{
  "scripts": {
    "build:dev": "webpack --mode=development --devtool=eval-source-map",
    "build:prod": "webpack --mode=production --devtool=source-map",
    "analyze": "webpack-bundle-analyzer dist/bundle.js"
  }
}
```

### **Fase 1 - Integraciones Específicas**

#### **1.2.8: DOM Testing Library**
```javascript
// tests/unit/dom-utils.test.js
import { screen } from '@testing-library/dom';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

describe('Price Display Component', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div id="livePrice">1.1659</div>
      <div id="priceChange" class="positive">+0.0012 (+0.10%)</div>
    `;
  });

  test('displays EUR/USD price correctly', () => {
    expect(screen.getByText('1.1659')).toBeInTheDocument();
  });

  test('shows price change with correct styling', () => {
    const priceChange = screen.getByText('+0.0012 (+0.10%)');
    expect(priceChange).toHaveClass('positive');
  });
});
```

#### **1.4.7: Content Security Policy**
```html
<!-- index.html header -->
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self' https://cdnjs.cloudflare.com 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  connect-src 'self' https://www.alphavantage.co wss://ws.finnhub.io;
  img-src 'self' data: https:;
  font-src 'self' https://fonts.gstatic.com;
">
```

### **Fase 2 - Integraciones Específicas**

#### **2.1.5.1: Exponential Backoff**
```javascript
// src/js/resilience-patterns.js
class ExponentialBackoff {
  constructor(baseDelay = 1000, maxDelay = 30000, maxRetries = 5) {
    this.baseDelay = baseDelay;
    this.maxDelay = maxDelay;
    this.maxRetries = maxRetries;
    this.jitterFactor = 0.1;
  }

  async execute(fn, retries = 0) {
    try {
      return await fn();
    } catch (error) {
      if (retries >= this.maxRetries) {
        throw new Error(`Max retries (${this.maxRetries}) exceeded: ${error.message}`);
      }
      
      const baseDelay = Math.min(
        this.baseDelay * Math.pow(2, retries),
        this.maxDelay
      );
      
      // Add jitter to prevent thundering herd
      const jitter = baseDelay * this.jitterFactor * Math.random();
      const delay = baseDelay + jitter;
      
      console.warn(`Attempt ${retries + 1} failed, retrying in ${delay}ms:`, error.message);
      
      await new Promise(resolve => setTimeout(resolve, delay));
      return this.execute(fn, retries + 1);
    }
  }
}

// Usage en api-manager.js
const backoff = new ExponentialBackoff();
const data = await backoff.execute(() => fetch(apiUrl));
```

#### **2.1.5.2: Circuit Breaker Pattern**
```javascript
// src/js/circuit-breaker.js
class CircuitBreaker {
  constructor(threshold = 5, resetTimeout = 60000) {
    this.threshold = threshold;
    this.resetTimeout = resetTimeout;
    this.failureCount = 0;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.nextAttempt = Date.now();
  }

  async execute(fn) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }

  onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.resetTimeout;
    }
  }
}
```

#### **2.4.5: Background Sync**
```javascript
// service-worker.js
self.addEventListener('sync', event => {
  if (event.tag === 'price-data-sync') {
    event.waitUntil(syncPriceData());
  }
});

async function syncPriceData() {
  try {
    const cachedRequests = await getCachedAPIRequests();
    const responses = await Promise.all(
      cachedRequests.map(request => fetch(request))
    );
    
    // Process responses and update cache
    for (const response of responses) {
      if (response.ok) {
        const data = await response.json();
        await updatePriceCache(data);
      }
    }
    
    // Notify main thread
    const clients = await self.clients.matchAll();
    clients.forEach(client => {
      client.postMessage({
        type: 'SYNC_COMPLETE',
        data: 'Price data synchronized'
      });
    });
  } catch (error) {
    console.error('Background sync failed:', error);
  }
}

// main.js - Register sync
if ('serviceWorker' in navigator && 'sync' in window.ServiceWorkerRegistration.prototype) {
  navigator.serviceWorker.ready.then(registration => {
    registration.sync.register('price-data-sync');
  });
}
```

### **Fase 3 - Integraciones Específicas**

#### **3.1.4.1: Web Workers para ML**
```javascript
// src/workers/ml-worker.js
importScripts('https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@latest/dist/tf.min.js');

let model = null;

self.onmessage = async function(e) {
  const { action, data, id } = e.data;
  
  try {
    switch (action) {
      case 'load-model':
        model = await tf.loadLayersModel(data.modelUrl);
        self.postMessage({ id, action: 'model-loaded', success: true });
        break;
        
      case 'predict':
        if (!model) {
          throw new Error('Model not loaded');
        }
        
        const tensor = tf.tensor2d([data.features]);
        const prediction = model.predict(tensor);
        const result = await prediction.data();
        
        tensor.dispose();
        prediction.dispose();
        
        self.postMessage({
          id,
          action: 'prediction-result',
          prediction: Array.from(result)
        });
        break;
    }
  } catch (error) {
    self.postMessage({
      id,
      action: 'error',
      error: error.message
    });
  }
};

// src/js/ml-manager.js
class MLManager {
  constructor() {
    this.worker = new Worker('src/workers/ml-worker.js');
    this.pendingRequests = new Map();
    this.worker.onmessage = this.handleWorkerMessage.bind(this);
  }
  
  handleWorkerMessage(e) {
    const { id, action, prediction, error } = e.data;
    const request = this.pendingRequests.get(id);
    
    if (request) {
      if (error) {
        request.reject(new Error(error));
      } else {
        request.resolve({ action, prediction });
      }
      this.pendingRequests.delete(id);
    }
  }
  
  predict(features) {
    return new Promise((resolve, reject) => {
      const id = Date.now() + Math.random();
      this.pendingRequests.set(id, { resolve, reject });
      
      this.worker.postMessage({
        id,
        action: 'predict',
        data: { features }
      });
    });
  }
}
```

### **Fase 4 - Integraciones Específicas**

#### **4.1.6: Session Management sin Backend**
```javascript
// src/js/auth-manager.js
class AuthManager {
  constructor() {
    this.tokenKey = 'eur_usd_session_token';
    this.userKey = 'eur_usd_user_data';
    this.sessionTimeout = 24 * 60 * 60 * 1000; // 24 hours
  }

  // Simulate authentication (replace with real auth service)
  async login(username, password) {
    // In production, this would call a real auth API
    const mockUser = {
      id: Date.now(),
      username,
      email: `${username}@example.com`,
      preferences: {
        theme: 'dark',
        defaultTimeframe: '1H',
        alerts: true
      },
      loginTime: Date.now()
    };

    const token = this.generateJWT(mockUser);
    
    localStorage.setItem(this.tokenKey, token);
    localStorage.setItem(this.userKey, JSON.stringify(mockUser));
    
    return { user: mockUser, token };
  }

  logout() {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.userKey);
    window.location.reload();
  }

  getCurrentUser() {
    const token = localStorage.getItem(this.tokenKey);
    const userData = localStorage.getItem(this.userKey);

    if (!token || !userData) return null;

    try {
      const user = JSON.parse(userData);
      
      // Check session expiry
      if (Date.now() - user.loginTime > this.sessionTimeout) {
        this.logout();
        return null;
      }

      return user;
    } catch (error) {
      console.error('Error parsing user data:', error);
      return null;
    }
  }

  generateJWT(user) {
    // Simple JWT simulation (use proper JWT library in production)
    const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
    const payload = btoa(JSON.stringify({
      userId: user.id,
      username: user.username,
      exp: Date.now() + this.sessionTimeout
    }));
    
    // In production, properly sign with secret key
    const signature = btoa(`signature_${user.id}_${Date.now()}`);
    
    return `${header}.${payload}.${signature}`;
  }

  updateUserPreferences(preferences) {
    const user = this.getCurrentUser();
    if (user) {
      user.preferences = { ...user.preferences, ...preferences };
      localStorage.setItem(this.userKey, JSON.stringify(user));
    }
  }
}

// Usage
const authManager = new AuthManager();

// Check authentication on app load
document.addEventListener('DOMContentLoaded', () => {
  const user = authManager.getCurrentUser();
  if (user) {
    console.log('User logged in:', user.username);
    loadUserPreferences(user.preferences);
  } else {
    showLoginForm();
  }
});
```

---

## 🎯 **Próximos Pasos Inmediatos (ACTUALIZADOS)**

### **Esta Semana (Prioridad MÁXIMA):**
1. **Día 1-2:** Completar Tarea 0.1 y 0.2 (subtareas originales)
2. **Día 3:** Completar Tarea 0.3 (incluyendo 0.3.5 y 0.3.6 si hay tiempo)
3. **Día 4:** Completar Tarea 0.4
4. **Día 5:** Setup de tracking system y primera retrospectiva

### **Próxima Semana:**
1. Comenzar Tarea 1.1 (System Architecture Document)
2. Setup de GitHub Projects para tracking
3. Implementar las primeras integraciones de testing (1.2.8)

### **Mes 1:**
1. Completar Fase 0 (18/18 subtareas) y 50% de Fase 1 (16/32 subtareas)
2. Establecer rutina de weekly reviews
3. Primer security audit completado con CSP headers

### **Decisión de Implementación:**

**OPCIÓN A (Conservador):** Implementar solo roadmap original (99 subtareas)
**OPCIÓN B (Balanceado):** Implementar roadmap + integraciones críticas (Fases 0-2)
**OPCIÓN C (Completo):** Implementar todo el roadmap integrado (113 subtareas)

---

## 📋 **Resumen de Cambios Realizados**

### **Subtareas Agregadas por Fase:**
- **Fase 0:** +2 subtareas (Webpack + Source Maps)
- **Fase 1:** +4 subtareas (DOM Testing + CSP + Visual Regression + SRI)
- **Fase 2:** +5 subtareas (Resilience Patterns + PWA avanzado)
- **Fase 3:** +2 subtareas (Web Workers + Offline ML)
- **Fase 4:** +1 subtarea (Session Management)

### **Tiempo Total Agregado:** +10.5 días (~1.5 semanas)

### **Beneficios de las Integraciones:**
- ✅ Mejor performance y bundling
- ✅ Testing más robusto
- ✅ Security mejorada
- ✅ Resilience para producción
- ✅ PWA capabilities avanzadas
- ✅ ML optimizado para Vanilla JS
- ✅ Auth sin dependencias de backend

**El roadmap integrado mantiene tu visión original mientras añade robustez técnica empresarial.**
