# 📋 Análisis Detallado: Fase 5 - Enterprise & Production

## **📊 RESUMEN EJECUTIVO**
- **3 Tareas Principales**
- **20 Subtareas Específicas** 
- **4 Métricas de Validación**
- **Duración Total: 4 semanas**
- **Prerequisito: Fase 4 completada (Multi-Asset & Microservices funcionando)**

*Aplicando la síntesis de Robert C. Martin, Martin Fowler, e Ian Sommerville: esta fase final transforma el sistema en una plataforma enterprise-grade lista para producción con miles de usuarios simultáneos.*

---

## **🏗️ TAREA 1: Production-Ready Deployment & Observability Stack**
*Duración estimada: 2 semanas*
*Siguiendo Martin Kleppmann's data-intensive systems principles + Ian Sommerville's systematic engineering approach*

### **Subtareas (8 items):**

**5.1.1** Infrastructure as Code (IaC) Implementation
```yaml
# Terraform siguiendo 12-factor app principles
# terraform/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
  
  backend "s3" {
    bucket = "trading-system-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-locks"
  }
}

# EKS Cluster con auto-scaling
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name    = "trading-system-prod"
  cluster_version = "1.28"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  # Managed node groups para different workloads
  eks_managed_node_groups = {
    # High-performance nodes para real-time processing
    trading_realtime = {
      name = "trading-realtime"
      instance_types = ["c6i.2xlarge"]
      min_size     = 3
      max_size     = 20
      desired_size = 6
      
      k8s_labels = {
        workload = "realtime"
        performance = "high"
      }
      
      taints = {
        realtime = {
          key    = "workload"
          value  = "realtime"
          effect = "NO_SCHEDULE"
        }
      }
    }
    
    # General purpose nodes para standard services
    trading_general = {
      name = "trading-general"
      instance_types = ["m6i.xlarge"]
      min_size     = 2
      max_size     = 15
      desired_size = 4
    }
    
    # ML-optimized nodes para analysis workloads
    trading_ml = {
      name = "trading-ml"
      instance_types = ["p3.2xlarge"] # GPU instances
      min_size     = 0
      max_size     = 5
      desired_size = 1
      
      k8s_labels = {
        workload = "ml"
        gpu = "enabled"
      }
    }
  }
  
  # IRSA para service accounts
  enable_irsa = true
}

# RDS Multi-AZ setup con read replicas
module "rds" {
  source = "terraform-aws-modules/rds/aws"
  
  identifier = "trading-system-prod"
  
  engine               = "postgres"
  engine_version       = "15.4"
  family              = "postgres15"
  major_engine_version = "15"
  instance_class      = "db.r6g.2xlarge"
  
  allocated_storage     = 1000
  max_allocated_storage = 5000
  storage_encrypted     = true
  
  # Multi-AZ deployment
  multi_az               = true
  publicly_accessible    = false
  
  # Read replicas para analytics
  create_random_password = true
  manage_master_user_password = true
  
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "Sun:04:00-Sun:05:00"
  
  deletion_protection = true
  
  performance_insights_enabled = true
  monitoring_interval = 60
  
  tags = {
    Environment = "production"
    System      = "trading"
  }
}

# ElastiCache Redis cluster
module "redis" {
  source = "terraform-aws-modules/elasticache/aws"
  
  cluster_id               = "trading-cache-prod"
  description             = "Trading system Redis cluster"
  node_type              = "cache.r6g.xlarge"
  port                   = 6379
  parameter_group_name   = "default.redis7"
  
  num_cache_clusters = 3
  
  # Redis configuration
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token_enabled = true
  
  # Automatic backups
  snapshot_retention_limit = 7
  snapshot_window         = "05:00-06:00"
  
  # Multi-AZ
  automatic_failover_enabled = true
  multi_az_enabled          = true
}
```

**5.1.2** Container Orchestration & GitOps
```yaml
# ArgoCD GitOps configuration
# k8s/applications/trading-system.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: trading-system
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  
  source:
    repoURL: https://github.com/yourorg/trading-system-k8s
    targetRevision: HEAD
    path: overlays/production
    
  destination:
    server: https://kubernetes.default.svc
    namespace: trading-system
    
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    
  revisionHistoryLimit: 10

---
# Kustomization for production environment
# overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: trading-system

resources:
- ../../base

patchesStrategicMerge:
- market-data-service-prod.yaml
- trading-service-prod.yaml
- analysis-service-prod.yaml

configMapGenerator:
- name: app-config
  files:
  - config/production.env

secretGenerator:
- name: api-keys
  files:
  - secrets/alpha-vantage-key
  - secrets/database-password
  - secrets/redis-auth-token

images:
- name: trading/market-data-service
  newTag: v1.2.3
- name: trading/trading-service  
  newTag: v1.2.3
- name: trading/analysis-service
  newTag: v1.2.3

replicas:
- name: market-data-service
  count: 6
- name: trading-service
  count: 4
- name: analysis-service
  count: 3
```

**5.1.3** Comprehensive Monitoring Stack
```yaml
# Prometheus + Grafana + Jaeger stack
# monitoring/prometheus-stack.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: kube-prometheus-stack
  namespace: monitoring
spec:
  chart: kube-prometheus-stack
  repo: https://prometheus-community.github.io/helm-charts
  targetNamespace: monitoring
  
  valuesContent: |-
    prometheus:
      prometheusSpec:
        retention: 30d
        retentionSize: 50GB
        storageSpec:
          volumeClaimTemplate:
            spec:
              storageClassName: gp3-encrypted
              accessModes: ["ReadWriteOnce"]
              resources:
                requests:
                  storage: 100Gi
        
        # Custom scrape configs para trading metrics
        additionalScrapeConfigs:
        - job_name: 'trading-services'
          kubernetes_sd_configs:
          - role: endpoints
            namespaces:
              names:
              - trading-system
          relabel_configs:
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
            action: keep
            regex: true
            
    grafana:
      adminPassword: "prom-operator"
      persistence:
        enabled: true
        size: 10Gi
        storageClassName: gp3-encrypted
        
      # Trading-specific dashboards
      dashboardProviders:
        dashboardproviders.yaml:
          apiVersion: 1
          providers:
          - name: 'trading-dashboards'
            orgId: 1
            folder: 'Trading System'
            type: file
            disableDeletion: false
            editable: true
            options:
              path: /var/lib/grafana/dashboards/trading
              
    alertmanager:
      config:
        global:
          slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
          
        route:
          group_by: ['alertname', 'severity']
          group_wait: 10s
          group_interval: 10s
          repeat_interval: 1h
          receiver: 'trading-alerts'
          
        receivers:
        - name: 'trading-alerts'
          slack_configs:
          - channel: '#trading-alerts'
            title: 'Trading System Alert'
            text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

**5.1.4** Custom Trading Metrics Implementation
```javascript
// Siguiendo Martin Fowler's enterprise monitoring patterns
class TradingMetricsCollector {
  constructor() {
    this.prometheus = require('prom-client');
    this.register = new this.prometheus.Registry();
    this.setupCustomMetrics();
  }
  
  setupCustomMetrics() {
    // Business metrics
    this.activeUsersGauge = new this.prometheus.Gauge({
      name: 'trading_active_users_total',
      help: 'Number of actively trading users',
      labelNames: ['region', 'account_type'],
      registers: [this.register]
    });
    
    this.tradeVolumeHistogram = new this.prometheus.Histogram({
      name: 'trading_volume_usd',
      help: 'Trading volume in USD',
      labelNames: ['asset_type', 'direction'],
      buckets: [1000, 5000, 10000, 50000, 100000, 500000, 1000000],
      registers: [this.register]
    });
    
    this.apiLatencyHistogram = new this.prometheus.Histogram({
      name: 'trading_api_request_duration_seconds',
      help: 'API request duration in seconds',
      labelNames: ['method', 'endpoint', 'status_code'],
      buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5],
      registers: [this.register]
    });
    
    this.mlPredictionAccuracy = new this.prometheus.Gauge({
      name: 'trading_ml_prediction_accuracy',
      help: 'ML model prediction accuracy percentage',
      labelNames: ['model_name', 'asset_type', 'timeframe'],
      registers: [this.register]
    });
    
    this.orderExecutionCounter = new this.prometheus.Counter({
      name: 'trading_orders_executed_total',
      help: 'Total number of orders executed',
      labelNames: ['asset_type', 'order_type', 'status'],
      registers: [this.register]
    });
    
    // Technical metrics
    this.connectionPoolGauge = new this.prometheus.Gauge({
      name: 'trading_db_connection_pool_size',
      help: 'Database connection pool size',
      labelNames: ['database', 'pool_type'],
      registers: [this.register]
    });
    
    this.cacheHitRatio = new this.prometheus.Gauge({
      name: 'trading_cache_hit_ratio',
      help: 'Cache hit ratio percentage',
      labelNames: ['cache_type', 'region'],
      registers: [this.register]
    });
  }
  
  // Business metrics recording
  recordTradeExecution(trade) {
    this.tradeVolumeHistogram
      .labels(trade.assetType, trade.direction)
      .observe(trade.volumeUSD);
      
    this.orderExecutionCounter
      .labels(trade.assetType, trade.orderType, trade.status)
      .inc();
  }
  
  recordMLPrediction(modelName, assetType, timeframe, accuracy) {
    this.mlPredictionAccuracy
      .labels(modelName, assetType, timeframe)
      .set(accuracy);
  }
  
  recordAPICall(method, endpoint, duration, statusCode) {
    this.apiLatencyHistogram
      .labels(method, endpoint, statusCode)
      .observe(duration);
  }
  
  // Health check endpoint
  getMetrics() {
    return this.register.metrics();
  }
}

// Trading-specific SLI/SLO definitions
class TradingSLOMonitor {
  constructor(metricsCollector) {
    this.metrics = metricsCollector;
    this.slos = {
      // 99.9% uptime (43.2 minutes downtime per month)
      availability: {
        target: 0.999,
        measurement: 'uptime_percentage',
        window: '30d'
      },
      
      // 95% of API calls < 200ms
      latency: {
        target: 0.95,
        measurement: 'api_response_time_p95',
        threshold: 0.200,
        window: '24h'
      },
      
      // 99.99% order execution success rate
      reliability: {
        target: 0.9999,
        measurement: 'order_success_rate',
        window: '24h'
      },
      
      // ML prediction accuracy > 60%
      accuracy: {
        target: 0.60,
        measurement: 'ml_prediction_accuracy_avg',
        window: '7d'
      }
    };
  }
  
  async calculateSLOCompliance(sloName, timeWindow) {
    const slo = this.slos[sloName];
    const query = this.buildPrometheusQuery(slo, timeWindow);
    const result = await this.queryPrometheus(query);
    
    return {
      slo: sloName,
      target: slo.target,
      actual: result.value,
      compliance: result.value >= slo.target,
      errorBudget: this.calculateErrorBudget(slo, result.value),
      recommendation: this.generateRecommendation(slo, result.value)
    };
  }
}
```

**5.1.5** Distributed Tracing Enhancement
```javascript
// OpenTelemetry siguiendo observability best practices
class EnterpriseTracingSetup {
  constructor() {
    this.setupTracing();
    this.setupCustomSpans();
  }
  
  setupTracing() {
    const { NodeSDK } = require('@opentelemetry/sdk-node');
    const { Resource } = require('@opentelemetry/resources');
    const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');
    
    const sdk = new NodeSDK({
      resource: new Resource({
        [SemanticResourceAttributes.SERVICE_NAME]: process.env.SERVICE_NAME,
        [SemanticResourceAttributes.SERVICE_VERSION]: process.env.SERVICE_VERSION,
        [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: process.env.NODE_ENV,
        [SemanticResourceAttributes.SERVICE_NAMESPACE]: 'trading-system'
      }),
      
      // Auto-instrumentation
      instrumentations: [
        getNodeAutoInstrumentations({
          '@opentelemetry/instrumentation-fs': { enabled: false }
        })
      ],
      
      // Export to Jaeger
      traceExporter: new JaegerExporter({
        endpoint: process.env.JAEGER_ENDPOINT
      }),
      
      // Sampling strategy
      sampler: new TraceIdRatioBasedSampler(0.1) // 10% sampling for production
    });
    
    sdk.start();
  }
  
  // Trading-specific span creation
  createTradingSpan(operationName, attributes = {}) {
    const tracer = opentelemetry.trace.getTracer('trading-system');
    
    return tracer.startSpan(operationName, {
      kind: SpanKind.INTERNAL,
      attributes: {
        'trading.operation': operationName,
        'trading.user_id': attributes.userId,
        'trading.asset': attributes.asset,
        'trading.order_type': attributes.orderType,
        ...attributes
      }
    });
  }
  
  // Cross-service correlation
  async traceOrderLifecycle(order) {
    const parentSpan = this.createTradingSpan('order_lifecycle', {
      userId: order.userId,
      asset: order.asset,
      orderType: order.type,
      volume: order.volume
    });
    
    return opentelemetry.trace.setSpan(
      opentelemetry.context.active(),
      parentSpan
    );
  }
}

// Custom middleware para automatic span creation
function tracingMiddleware(req, res, next) {
  const tracer = opentelemetry.trace.getTracer('api-gateway');
  
  const span = tracer.startSpan(`${req.method} ${req.route?.path || req.path}`, {
    kind: SpanKind.SERVER,
    attributes: {
      'http.method': req.method,
      'http.url': req.url,
      'http.route': req.route?.path,
      'user.id': req.user?.id,
      'trading.tenant': req.headers['x-tenant-id']
    }
  });
  
  // Add span to response headers for frontend correlation
  res.setHeader('x-trace-id', span.spanContext().traceId);
  
  res.on('finish', () => {
    span.setAttributes({
      'http.status_code': res.statusCode,
      'http.response_size': res.get('content-length')
    });
    
    if (res.statusCode >= 400) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: `HTTP ${res.statusCode}`
      });
    }
    
    span.end();
  });
  
  next();
}
```

**5.1.6** Automated Backup & Disaster Recovery
```yaml
# Velero backup configuration
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: aws-backup-location
  namespace: velero
spec:
  provider: aws
  objectStorage:
    bucket: trading-system-backups
    prefix: velero
  config:
    region: us-east-1
    s3ForcePathStyle: "false"

---
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: trading-system-daily-backup
  namespace: velero
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  template:
    includedNamespaces:
    - trading-system
    - monitoring
    
    excludedResources:
    - pods
    - replicasets
    
    includeClusterResources: true
    
    ttl: 720h  # 30 days retention
    
    storageLocation: aws-backup-location
    
    hooks:
      resources:
      - name: postgres-backup-hook
        includedNamespaces:
        - trading-system
        includedResources:
        - pods
        labelSelector:
          matchLabels:
            app: postgres
        pre:
        - exec:
            container: postgres
            command:
            - /bin/bash
            - -c
            - "pg_dump trading_prod > /tmp/backup.sql"
        post:
        - exec:
            container: postgres
            command:
            - /bin/bash
            - -c
            - "rm -f /tmp/backup.sql"
```

**5.1.7** Log Aggregation & Analysis
```yaml
# ELK Stack configuration
apiVersion: logging.coreos.com/v1
kind: ClusterLogForwarder
metadata:
  name: trading-log-forwarder
  namespace: openshift-logging
spec:
  outputs:
  - name: elasticsearch-trading
    type: elasticsearch
    url: https://elasticsearch.trading-system.local:9200
    elasticsearch:
      index: trading-logs-{.log_type}-{.kubernetes.namespace_name}-{+yyyy.MM.dd}
    secret:
      name: elasticsearch-secret
      
  pipelines:
  - name: trading-application-logs
    inputRefs:
    - application
    filterRefs:
    - trading-log-filter
    outputRefs:
    - elasticsearch-trading
    
  - name: trading-infrastructure-logs
    inputRefs:
    - infrastructure
    filterRefs:
    - infrastructure-filter
    outputRefs:
    - elasticsearch-trading

---
apiVersion: logging.coreos.com/v1
kind: ClusterLogFilter
metadata:
  name: trading-log-filter
spec:
  type: json
  json:
    javascript: |
      const log = record.log;
      
      // Parse structured logs
      if (log && typeof log === 'string') {
        try {
          const parsed = JSON.parse(log);
          record.parsed = parsed;
          
          // Extract trading-specific fields
          if (parsed.trade_id) {
            record.trade_id = parsed.trade_id;
          }
          if (parsed.user_id) {
            record.user_id = parsed.user_id;
          }
          if (parsed.asset) {
            record.asset = parsed.asset;
          }
          
        } catch (e) {
          record.parse_error = e.message;
        }
      }
      
      return record;
```

**5.1.8** Performance Testing & Load Simulation
```javascript
// K6 load testing siguiendo performance engineering best practices
import http from 'k6/http';
import ws from 'k6/ws';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('trading_error_rate');
const orderLatency = new Trend('trading_order_latency');
const wsConnectionSuccess = new Rate('ws_connection_success');

// Test configuration
export const options = {
  scenarios: {
    // Normal trading load
    normal_trading: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 100 },   // Ramp up
        { duration: '30m', target: 100 },  // Stay at 100 users
        { duration: '5m', target: 0 },     // Ramp down
      ],
      tags: { test_type: 'normal_load' }
    },
    
    // Market volatility spike simulation
    volatility_spike: {
      executor: 'ramping-arrival-rate',
      startRate: 10,
      timeUnit: '1s',
      preAllocatedVUs: 50,
      maxVUs: 500,
      stages: [
        { duration: '2m', target: 50 },    // Normal rate
        { duration: '1m', target: 500 },   // Spike to 500 RPS
        { duration: '2m', target: 50 },    // Back to normal
      ],
      tags: { test_type: 'spike_test' }
    },
    
    // WebSocket connections test
    realtime_connections: {
      executor: 'constant-vus',
      vus: 200,
      duration: '30m',
      tags: { test_type: 'websocket_test' }
    }
  },
  
  thresholds: {
    http_req_duration: ['p(95)<200', 'p(99)<500'],
    http_req_failed: ['rate<0.01'],
    trading_order_latency: ['p(95)<100'],
    trading_error_rate: ['rate<0.005'],
    ws_connection_success: ['rate>0.99']
  }
};

// API authentication
function authenticate() {
  const authResponse = http.post(`${__ENV.API_BASE_URL}/auth/login`, {
    username: `testuser${Math.floor(Math.random() * 1000)}`,
    password: 'testpass123'
  });
  
  check(authResponse, {
    'authentication successful': (r) => r.status === 200
  });
  
  return authResponse.json('token');
}

// Trading workflow simulation
export default function () {
  const token = authenticate();
  const headers = { 
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  };
  
  // Fetch market data
  const marketDataResponse = http.get(
    `${__ENV.API_BASE_URL}/api/market-data/EURUSD`,
    { headers }
  );
  
  check(marketDataResponse, {
    'market data fetched': (r) => r.status === 200,
    'market data has price': (r) => r.json('price') !== undefined
  });
  
  // Place a test order
  const orderPayload = {
    asset: 'EURUSD',
    type: 'market',
    direction: Math.random() > 0.5 ? 'buy' : 'sell',
    quantity: 10000,
    stopLoss: 1.1600,
    takeProfit: 1.1700
  };
  
  const orderStart = Date.now();
  const orderResponse = http.post(
    `${__ENV.API_BASE_URL}/api/trading/orders`,
    JSON.stringify(orderPayload),
    { headers }
  );
  
  const orderDuration = Date.now() - orderStart;
  orderLatency.add(orderDuration);
  
  const orderSuccess = check(orderResponse, {
    'order placed successfully': (r) => r.status === 201,
    'order has ID': (r) => r.json('orderId') !== undefined
  });
  
  errorRate.add(!orderSuccess);
  
  sleep(Math.random() * 5 + 1); // Random think time 1-6 seconds
}

// WebSocket testing function
export function websocketTest() {
  const url = `${__ENV.WS_BASE_URL}/ws/market-data`;
  const params = { tags: { test_type: 'websocket' } };
  
  const response = ws.connect(url, params, function (socket) {
    wsConnectionSuccess.add(true);
    
    socket.on('open', () => {
      console.log('WebSocket connected');
      
      // Subscribe to EUR/USD updates
      socket.send(JSON.stringify({
        action: 'subscribe',
        symbol: 'EURUSD',
        timeframe: '1m'
      }));
    });
    
    socket.on('message', (data) => {
      const message = JSON.parse(data);
      check(message, {
        'valid market data': (msg) => msg.symbol && msg.price
      });
    });
    
    socket.on('error', (error) => {
      console.error('WebSocket error:', error);
      wsConnectionSuccess.add(false);
    });
    
    // Keep connection open for test duration
    sleep(30);
    
    socket.close();
  });
  
  if (!response) {
    wsConnectionSuccess.add(false);
  }
}
```

---

## **🔐 TAREA 2: Security, Compliance & Governance Framework**
*Duración estimada: 1.5 semanas*
*Aplicando principios de Zero Trust Architecture + financial services compliance standards*

### **Subtareas (7 items):**

**5.2.1** Identity & Access Management (IAM) Enterprise
```javascript
// Auth0/Keycloak integration siguiendo OAUTH 2.0 + OIDC best practices
class EnterpriseAuthManager {
  constructor() {
    this.auth0 = new Auth0Management({
      domain: process.env.AUTH0_DOMAIN,
      clientId: process.env.AUTH0_CLIENT_ID,
      clientSecret: process.env.AUTH0_CLIENT_SECRET,
      scope: 'read:users update:users read:roles create:roles'
    });
    
    this.rbac = new RoleBasedAccessControl();
    this.setupRoles();
  }
  
  setupRoles() {
    // Hierarchical role structure para financial services
    this.rbac.addRole('viewer', [], 'Read-only access to market data');
    this.rbac.addRole('trader', ['viewer'], 'Execute trades within limits');
    this.rbac.addRole('senior_trader', ['trader'], 'Higher trading limits');
    this.rbac.addRole('risk_manager', ['viewer'], 'Risk monitoring and limits');
    this.rbac.addRole('compliance_officer', ['viewer'], 'Audit and compliance');
    this.rbac.addRole('admin', ['risk_manager', 'compliance_officer'], 'System administration');
    
    // Granular permissions
    const permissions = {
      'market_data:read': ['viewer', 'trader', 'senior_trader', 'risk_manager', 'compliance_officer', 'admin'],
      'orders:create': ['trader', 'senior_trader'],
      'orders:cancel': ['trader', 'senior_trader'],
      'positions:view': ['trader', 'senior_trader', 'risk_manager'],
      'positions:close': ['trader', 'senior_trader'],
      'reports:generate': ['risk_manager', 'compliance_officer', 'admin'],
      'users:manage': ['admin'],
      'system:configure': ['admin']
    };
    
    Object.entries(permissions).forEach(([permission, roles]) => {
      roles.forEach(role => {
        this.rbac.addPermission(role, permission);
      });
    });
  }
  
  async authenticateUser(token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await this.auth0.getUser({ id: decoded.sub });
      
      return {
        id: user.user_id,
        email: user.email,
        roles: user.app_metadata?.roles || ['viewer'],
        permissions: this.getUserPermissions(user.app_metadata?.roles || ['viewer']),
        mfaEnabled: user.multifactor?.length > 0,
        lastLogin: user.last_login,
        tenant: user.app_metadata?.tenant
      };
    } catch (error) {
      throw new AuthenticationError('Invalid token');
    }
  }
  
  async authorizeAction(user, resource, action) {
    const permission = `${resource}:${action}`;
    
    if (!user.permissions.includes(permission)) {
      throw new AuthorizationError(`Insufficient permissions for ${permission}`);
    }
    
    // Additional checks para financial operations
    if (resource === 'orders' && action === 'create') {
      await this.checkTradingLimits(user);
      await this.checkMarketHours();
      await this.checkRiskLimits(user);
    }
    
    return true;
  }
  
  async checkTradingLimits(user) {
    const limits = await this.getTradingLimits(user.id);
    const currentExposure = await this.getCurrentExposure(user.id);
    
    if (currentExposure.totalValue > limits.maxExposure) {
      throw new RiskLimitError('Maximum exposure limit exceeded');
    }
    
    const dailyVolume = await this.getDailyTradingVolume(user.id);
    if (dailyVolume > limits.dailyVolumeLimit) {
      throw new RiskLimitError('Daily volume limit exceeded');
    }
  }
}

// JWT middleware con rate limiting
class SecureAuthMiddleware {
  constructor() {
    this.rateLimiter = new RateLimiter({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 1000, // limit each IP to 1000 requests per windowMs
      standardHeaders: true,
      legacyHeaders: false
    });
    
    this.authLimiter = new RateLimiter({
      windowMs: 15 * 60 * 1000,
      max: 5, // limit each IP to 5 failed auth attempts per windowMs
      skipSuccessfulRequests: true
    });
  }
  
  authenticate() {
    return async (req, res, next) => {
      try {
        // Apply rate limiting
        await this.rateLimiter.middleware()(req, res, () => {});
        
        const token = this.extractToken(req);
        if (!token) {
          await this.authLimiter.middleware()(req, res, () => {});
          return res.status(401).json({ error: 'No token provided' });
        }
        
        const user = await this.authManager.authenticateUser(token);
        
        // Check if MFA is required
        if (this.requiresMFA(req) && !user.mfaEnabled) {
          return res.status(403).json({ error: 'MFA required for this operation' });
        }
        
        req.user = user;
        req.permissions = user.permissions;
        
        next();
      } catch (error) {
        await this.authLimiter.middleware()(req, res, () => {});
        res.status(401).json({ error: error.message });
      }
    };
  }
  
  authorize(resource, action) {
    return async (req, res, next) => {
      try {
        await this.authManager.authorizeAction(req.user, resource, action);
        next();
      } catch (error) {
        res.status(403).json({ error: error.message });
      }
    };
  }
}
```

**5.2.2** Data Encryption & Privacy Protection
```javascript
// Siguiendo GDPR + financial data protection requirements
class DataProtectionManager {
  constructor() {
    this.encryption = new AdvancedEncryption();
    this.piiDetector = new PIIDetector();
    this.dataClassifier = new DataClassifier();
    this.setupEncryptionKeys();
  }
  
  setupEncryptionKeys() {
    // Key rotation every 90 days para compliance
    this.encryptionKeys = {
      pii: process.env.PII_ENCRYPTION_KEY,
      financial: process.env.FINANCIAL_ENCRYPTION_KEY,
      general: process.env.GENERAL_ENCRYPTION_KEY
    };
    
    // Key derivation para different data types
    this.keyManager = new KeyManager({
      masterKey: process.env.MASTER_ENCRYPTION_KEY,
      rotationPeriod: 90 * 24 * 60 * 60 * 1000 // 90 days
    });
  }
  
  async encryptSensitiveData(data, dataType) {
    const classification = this.dataClassifier.classify(data);
    const key = this.selectEncryptionKey(classification);
    
    if (classification.includes('PII')) {
      // Apply tokenization para PII data
      return this.tokenizePII(data, key);
    } else if (classification.includes('FINANCIAL')) {
      // Field-level encryption para financial data
      return this.encryptFinancialData(data, key);
    } else {
      // Standard encryption
      return this.encryption.encrypt(data, key);
    }
  }
  
  async tokenizePII(data, key) {
    const tokens = {};
    
    for (const [field, value] of Object.entries(data)) {
      if (this.piiDetector.isPII(field, value)) {
        // Generate irreversible token
        const token = await this.generateToken(value, key);
        tokens[field] = token;
        
        // Store mapping en secure vault
        await this.storeTokenMapping(token, value, key);
      } else {
        tokens[field] = value;
      }
    }
    
    return tokens;
  }
  
  async encryptFinancialData(data, key) {
    const encrypted = { ...data };
    
    // Campos que requieren encryption
    const sensitiveFields = [
      'account_number', 'balance', 'credit_card', 
      'bank_account', 'trading_limits', 'net_worth'
    ];
    
    for (const field of sensitiveFields) {
      if (encrypted[field] !== undefined) {
        encrypted[field] = await this.encryption.encryptField(
          encrypted[field], 
          key, 
          { algorithm: 'AES-256-GCM', includeAAD: true }
        );
      }
    }
    
    return encrypted;
  }
  
  // GDPR compliance methods
  async handleDataSubjectRequest(requestType, userId, data = null) {
    switch (requestType) {
      case 'access':
        return this.exportUserData(userId);
        
      case 'rectification':
        return this.updateUserData(userId, data);
        
      case 'erasure':
        return this.deleteUserData(userId);
        
      case 'portability':
        return this.exportPortableData(userId);
        
      case 'restrict':
        return this.restrictProcessing(userId);
        
      default:
        throw new Error('Invalid data subject request type');
    }
  }
  
  async exportUserData(userId) {
    // Collect all user data across services
    const userData = {
      profile: await this.getUserProfile(userId),
      tradingHistory: await this.getTradingHistory(userId),
      preferences: await this.getUserPreferences(userId),
      auditLog: await this.getAuditLog(userId)
    };
    
    // Decrypt sensitive data para export
    for (const [section, data] of Object.entries(userData)) {
      userData[section] = await this.decryptForExport(data);
    }
    
    return userData;
  }
  
  async deleteUserData(userId) {
    // Right to be forgotten implementation
    const deletionPlan = await this.createDeletionPlan(userId);
    
    for (const service of deletionPlan.services) {
      await this.deleteFromService(service, userId);
    }
    
    // Create deletion certificate
    return this.generateDeletionCertificate(userId, deletionPlan);
  }
}

// Database-level encryption
class DatabaseEncryption {
  constructor() {
    this.setupColumnEncryption();
  }
  
  setupColumnEncryption() {
    // PostgreSQL TDE (Transparent Data Encryption) configuration
    this.encryptedColumns = {
      users: ['email', 'phone_number', 'address', 'tax_id'],
      trading_accounts: ['account_number', 'balance', 'credit_limit'],
      transactions: ['amount', 'fees', 'net_amount'],
      audit_logs: ['sensitive_data', 'pii_fields']
    };
  }
  
  createEncryptedTable(tableName, schema) {
    const encryptedSchema = { ...schema };
    
    // Apply encryption to designated columns
    if (this.encryptedColumns[tableName]) {
      this.encryptedColumns[tableName].forEach(column => {
        if (encryptedSchema[column]) {
          encryptedSchema[column].encrypt = true;
          encryptedSchema[column].keyId = 'default_encryption_key';
        }
      });
    }
    
    return encryptedSchema;
  }
}
```

**5.2.3** Audit Logging & Compliance Monitoring
```javascript
// Comprehensive audit trail siguiendo SOX + GDPR requirements
class ComplianceAuditSystem {
  constructor() {
    this.auditLogger = new StructuredLogger('compliance-audit');
    this.eventClassifier = new ComplianceEventClassifier();
    this.alertManager = new ComplianceAlertManager();
    this.setupAuditRules();
  }
  
  setupAuditRules() {
    this.auditRules = {
      // Financial events - must be logged
      financial: {
        events: ['order_created', 'order_executed', 'position_opened', 'position_closed'],
        retention: '7_years',
        immutable: true,
        realTimeAlert: true
      },
      
      // Data access events
      dataAccess: {
        events: ['user_data_accessed', 'report_generated', 'export_created'],
        retention: '3_years',
        immutable: true,
        realTimeAlert: false
      },
      
      // Security events
      security: {
        events: ['login_failed', 'permission_denied', 'suspicious_activity'],
        retention: '5_years',
        immutable: true,
        realTimeAlert: true
      },
      
      // Administrative events
      administrative: {
        events: ['user_created', 'role_changed', 'system_config_modified'],
        retention: '5_years',
        immutable: true,
        realTimeAlert: true
      }
    };
  }
  
  async logEvent(eventType, eventData, context = {}) {
    const timestamp = new Date().toISOString();
    const eventId = this.generateEventId();
    
    const auditEntry = {
      event_id: eventId,
      timestamp,
      event_type: eventType,
      classification: this.eventClassifier.classify(eventType),
      
      // Actor information
      actor: {
        user_id: context.userId,
        session_id: context.sessionId,
        ip_address: context.ipAddress,
        user_agent: context.userAgent,
        roles: context.userRoles
      },
      
      // Event details
      event_data: this.sanitizeEventData(eventData),
      
      // Technical context
      technical_context: {
        service: context.serviceName,
        version: context.serviceVersion,
        trace_id: context.traceId,
        request_id: context.requestId
      },
      
      // Compliance metadata
      compliance: {
        retention_period: this.getRetentionPeriod(eventType),
        data_classification: this.classifyDataSensitivity(eventData),
        regulatory_tags: this.getRegulatoryTags(eventType)
      }
    };
    
    // Digital signature para tamper detection
    auditEntry.signature = await this.signAuditEntry(auditEntry);
    
    // Store en immutable audit log
    await this.storeAuditEntry(auditEntry);
    
    // Check for compliance violations
    await this.checkComplianceViolations(auditEntry);
    
    return eventId;
  }
  
  async checkComplianceViolations(auditEntry) {
    const violations = [];
    
    // Check for suspicious patterns
    if (await this.detectSuspiciousActivity(auditEntry)) {
      violations.push({
        type: 'suspicious_activity',
        severity: 'high',
        description: 'Unusual trading pattern detected'
      });
    }
    
    // Check trading limits
    if (auditEntry.event_type === 'order_created') {
      const limitViolation = await this.checkTradingLimits(auditEntry);
      if (limitViolation) {
        violations.push(limitViolation);
      }
    }
    
    // Check data access patterns
    if (auditEntry.classification === 'dataAccess') {
      const accessViolation = await this.checkDataAccessPatterns(auditEntry);
      if (accessViolation) {
        violations.push(accessViolation);
      }
    }
    
    // Alert compliance team if violations found
    if (violations.length > 0) {
      await this.alertManager.sendComplianceAlert({
        event_id: auditEntry.event_id,
        violations,
        audit_entry: auditEntry
      });
    }
  }
  
  // Compliance reporting
  async generateComplianceReport(reportType, startDate, endDate, filters = {}) {
    const reportId = this.generateReportId();
    
    const reportConfig = {
      sox: {
        title: 'SOX Compliance Report',
        events: ['financial', 'administrative'],
        sections: ['trading_activity', 'user_management', 'system_changes']
      },
      
      gdpr: {
        title: 'GDPR Data Processing Report',
        events: ['dataAccess', 'dataModification', 'dataExport'],
        sections: ['data_subject_requests', 'consent_management', 'data_breaches']
      },
      
      mifid: {
        title: 'MiFID II Transaction Reporting',
        events: ['financial'],
        sections: ['transaction_details', 'best_execution', 'client_categorization']
      }
    };
    
    const config = reportConfig[reportType];
    if (!config) {
      throw new Error(`Unsupported report type: ${reportType}`);
    }
    
    // Generate report data
    const reportData = await this.collectReportData(config, startDate, endDate, filters);
    
    // Create formatted report
    const report = await this.formatComplianceReport(config, reportData);
    
    // Store report
    await this.storeComplianceReport(reportId, report);
    
    // Log report generation
    await this.logEvent('compliance_report_generated', {
      report_id: reportId,
      report_type: reportType,
      period: { start: startDate, end: endDate }
    });
    
    return {
      report_id: reportId,
      report_url: await this.generateReportURL(reportId),
      generated_at: new Date().toISOString()
    };
  }
}

// Real-time compliance monitoring
class RealTimeComplianceMonitor {
  constructor() {
    this.ruleEngine = new ComplianceRuleEngine();
    this.alertManager = new ComplianceAlertManager();
    this.setupMonitoringRules();
  }
  
  setupMonitoringRules() {
    // Trading volume limits
    this.ruleEngine.addRule('daily_volume_limit', {
      condition: (event) => {
        return event.event_type === 'order_executed' &&
               event.daily_volume > event.actor.daily_limit;
      },
      action: 'block_future_orders',
      alert: 'immediate'
    });
    
    // Unusual market hours activity
    this.ruleEngine.addRule('after_hours_trading', {
      condition: (event) => {
        const hour = new Date(event.timestamp).getUTCHours();
        return event.event_type === 'order_created' &&
               (hour < 8 || hour > 17); // Outside normal market hours
      },
      action: 'require_approval',
      alert: 'immediate'
    });
    
    // Multiple failed login attempts
    this.ruleEngine.addRule('brute_force_detection', {
      condition: (event) => {
        return event.event_type === 'login_failed' &&
               event.recent_failures > 5;
      },
      action: 'lock_account',
      alert: 'immediate'
    });
  }
  
  async processEvent(auditEntry) {
    const violations = await this.ruleEngine.evaluate(auditEntry);
    
    for (const violation of violations) {
      await this.handleViolation(violation, auditEntry);
    }
  }
  
  async handleViolation(violation, auditEntry) {
    // Execute automatic actions
    switch (violation.action) {
      case 'block_future_orders':
        await this.blockUserTrading(auditEntry.actor.user_id);
        break;
        
      case 'require_approval':
        await this.requireManagerApproval(auditEntry);
        break;
        
      case 'lock_account':
        await this.lockUserAccount(auditEntry.actor.user_id);
        break;
    }
    
    // Send alerts
    if (violation.alert === 'immediate') {
      await this.alertManager.sendImmediateAlert(violation, auditEntry);
    }
    
    // Log the violation
    await this.logComplianceViolation(violation, auditEntry);
  }
}
```

**5.2.4** Vulnerability Management & Security Scanning
```yaml
# Integrated security scanning pipeline
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-scan-config
  namespace: trading-system
data:
  trivy-config.yaml: |
    # Container vulnerability scanning
    scan:
      security-checks:
        - vuln
        - config
        - secret
      severity:
        - CRITICAL
        - HIGH
        - MEDIUM
      ignore-unfixed: false
      
    db:
      repositories:
        - ghcr.io/aquasecurity/trivy-db
      
    output:
      format: json
      
  sonarqube-config.properties: |
    # Code quality and security scanning
    sonar.projectKey=trading-system
    sonar.projectName=Trading System
    sonar.sources=src
    sonar.tests=tests
    sonar.exclusions=**/node_modules/**,**/dist/**
    
    # Security-specific rules
    sonar.security.hotspots.inherited=true
    sonar.security.review.rating=A
    
  dependency-check.xml: |
    <?xml version="1.0" encoding="UTF-8"?>
    <dependency-check>
      <settings>
        <autoUpdate>true</autoUpdate>
        <suppressionFile>suppression.xml</suppressionFile>
      </settings>
      
      <analyzers>
        <nodeAudit enabled="true"/>
        <retireJs enabled="true"/>
        <ossIndex enabled="true"/>
      </analyzers>
      
      <formats>
        <format>JSON</format>
        <format>HTML</format>
      </formats>
    </dependency-check>

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: security-scan-job
  namespace: trading-system
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: security-scanner
            image: aquasec/trivy:latest
            command:
            - /bin/sh
            - -c
            - |
              # Scan container images
              trivy image --config /config/trivy-config.yaml trading/market-data-service:latest
              trivy image --config /config/trivy-config.yaml trading/trading-service:latest
              
              # Scan filesystem
              trivy fs --config /config/trivy-config.yaml /app
              
              # Upload results to security dashboard
              curl -X POST "${SECURITY_DASHBOARD_URL}/scan-results" \
                -H "Authorization: Bearer ${API_TOKEN}" \
                -H "Content-Type: application/json" \
                -d @scan-results.json
                
            volumeMounts:
            - name: config
              mountPath: /config
              
          volumes:
          - name: config
            configMap:
              name: security-scan-config
              
          restartPolicy: OnFailure
```

**5.2.5** Incident Response & Security Operations
```javascript
// Security Incident Response siguiendo NIST framework
class SecurityIncidentManager {
  constructor() {
    this.alertProcessor = new SecurityAlertProcessor();
    this.responseTeam = new IncidentResponseTeam();
    this.communicationManager = new CrisisCommunicationManager();
    this.setupIncidentCategories();
  }
  
  setupIncidentCategories() {
    this.incidentCategories = {
      'data_breach': {
        severity: 'critical',
        responseTime: '15_minutes',
        escalationPath: ['security_lead', 'ciso', 'ceo'],
        requiredActions: ['isolate_affected_systems', 'preserve_evidence', 'notify_authorities']
      },
      
      'unauthorized_access': {
        severity: 'high',
        responseTime: '30_minutes',
        escalationPath: ['security_analyst', 'security_lead'],
        requiredActions: ['block_suspicious_ips', 'reset_compromised_accounts', 'audit_access_logs']
      },
      
      'ddos_attack': {
        severity: 'high',
        responseTime: '15_minutes',
        escalationPath: ['network_admin', 'security_lead'],
        requiredActions: ['activate_ddos_protection', 'scale_infrastructure', 'monitor_performance']
      },
      
      'malware_detection': {
        severity: 'medium',
        responseTime: '1_hour',
        escalationPath: ['security_analyst'],
        requiredActions: ['quarantine_infected_systems', 'run_full_scan', 'update_signatures']
      }
    };
  }
  
  async handleSecurityAlert(alert) {
    const incidentId = this.generateIncidentId();
    
    // Classify the incident
    const classification = await this.classifyIncident(alert);
    const category = this.incidentCategories[classification.category];
    
    // Create incident record
    const incident = {
      id: incidentId,
      timestamp: new Date().toISOString(),
      category: classification.category,
      severity: category.severity,
      source: alert.source,
      description: alert.description,
      affected_systems: alert.affectedSystems,
      status: 'new',
      assignee: null,
      timeline: []
    };
    
    // Start response process
    await this.initiateResponse(incident, category);
    
    return incidentId;
  }
  
  async initiateResponse(incident, category) {
    // Start timer para response time tracking
    const responseTimer = this.startResponseTimer(incident.id, category.responseTime);
    
    // Execute automatic containment actions
    for (const action of category.requiredActions) {
      await this.executeContainmentAction(action, incident);
    }
    
    // Notify response team
    await this.notifyResponseTeam(incident, category.escalationPath);
    
    // Start evidence collection
    await this.startEvidenceCollection(incident);
    
    // Update incident status
    await this.updateIncidentStatus(incident.id, 'in_progress');
  }
  
  async executeContainmentAction(action, incident) {
    switch (action) {
      case 'isolate_affected_systems':
        await this.isolateSystems(incident.affected_systems);
        break;
        
      case 'block_suspicious_ips':
        await this.blockSuspiciousIPs(incident);
        break;
        
      case 'reset_compromised_accounts':
        await this.resetCompromisedAccounts(incident);
        break;
        
      case 'activate_ddos_protection':
        await this.activateDDoSProtection();
        break;
        
      case 'quarantine_infected_systems':
        await this.quarantineInfectedSystems(incident.affected_systems);
        break;
    }
    
    // Log the action
    await this.logIncidentAction(incident.id, action, 'completed');
  }
  
  // Evidence collection and forensics
  async startEvidenceCollection(incident) {
    const evidenceCollector = new DigitalForensicsCollector();
    
    // Collect system logs
    const systemLogs = await evidenceCollector.collectSystemLogs(
      incident.affected_systems,
      incident.timestamp
    );
    
    // Collect network traffic
    const networkTraffic = await evidenceCollector.captureNetworkTraffic(
      incident.affected_systems
    );
    
    // Collect memory dumps if necessary
    if (incident.category === 'malware_detection') {
      const memoryDumps = await evidenceCollector.collectMemoryDumps(
        incident.affected_systems
      );
    }
    
    // Store evidence securely
    const evidencePackage = await evidenceCollector.createEvidencePackage({
      incident_id: incident.id,
      system_logs: systemLogs,
      network_traffic: networkTraffic,
      collection_timestamp: new Date().toISOString()
    });
    
    await this.storeEvidence(incident.id, evidencePackage);
  }
  
  // Post-incident activities
  async conductPostIncidentReview(incidentId) {
    const incident = await this.getIncident(incidentId);
    
    const review = {
      incident_id: incidentId,
      review_date: new Date().toISOString(),
      timeline_analysis: await this.analyzeResponseTimeline(incident),
      root_cause: await this.determineRootCause(incident),
      lessons_learned: await this.identifyLessonsLearned(incident),
      improvement_actions: await this.recommendImprovements(incident),
      compliance_impact: await this.assessComplianceImpact(incident)
    };
    
    // Update security procedures based on lessons learned
    await this.updateSecurityProcedures(review.improvement_actions);
    
    // Schedule follow-up actions
    await this.scheduleFollowUpActions(review);
    
    return review;
  }
}
```

**5.2.6** Regulatory Compliance Automation
```javascript
// Multi-jurisdiction compliance management
class RegulatoryComplianceManager {
  constructor() {
    this.jurisdictions = new Map();
    this.setupJurisdictions();
    this.complianceCheckers = new Map();
    this.reportGenerators = new Map();
  }
  
  setupJurisdictions() {
    // EU - MiFID II compliance
    this.jurisdictions.set('EU', {
      regulations: ['MIFID_II', 'GDPR', 'EMIR'],
      reportingRequirements: {
        'transaction_reporting': {
          frequency: 'real_time',
          regulator: 'ESMA',
          format: 'XML',
          fields: ['instrument_id', 'transaction_price', 'quantity', 'timestamp']
        },
        'best_execution': {
          frequency: 'quarterly',
          regulator: 'ESMA',
          format: 'RTS28',
          deadline: '30_days_after_quarter'
        }
      },
      dataResidency: 'EU_only',
      consentRequired: true
    });
    
    // US - Dodd-Frank compliance
    this.jurisdictions.set('US', {
      regulations: ['DODD_FRANK', 'SOX', 'FINRA'],
      reportingRequirements: {
        'swap_data_reporting': {
          frequency: 'real_time',
          regulator: 'CFTC',
          format: 'FpML',
          fields: ['usi', 'product_data', 'counterparty_data']
        },
        'large_trader_reporting': {
          frequency: 'monthly',
          regulator: 'SEC',
          format: '13F',
          threshold: '100M_USD'
        }
      },
      dataResidency: 'flexible',
      consentRequired: false
    });
    
    // UK - FCA requirements
    this.jurisdictions.set('UK', {
      regulations: ['UK_MIFIR', 'GDPR_UK', 'PRA'],
      reportingRequirements: {
        'transaction_reporting': {
          frequency: 'real_time',
          regulator: 'FCA',
          format: 'XML',
          fields: ['venue', 'instrument', 'price', 'quantity']
        }
      },
      dataResidency: 'UK_preferred',
      consentRequired: true
    });
  }
  
  async checkTransactionCompliance(transaction, userJurisdiction) {
    const jurisdiction = this.jurisdictions.get(userJurisdiction);
    const complianceResults = [];
    
    for (const regulation of jurisdiction.regulations) {
      const checker = this.getComplianceChecker(regulation);
      const result = await checker.checkTransaction(transaction);
      complianceResults.push(result);
    }
    
    // Aggregate results
    const overallCompliance = {
      compliant: complianceResults.every(r => r.compliant),
      violations: complianceResults.flatMap(r => r.violations || []),
      required_reports: this.determineRequiredReports(transaction, jurisdiction),
      data_handling_requirements: this.getDataHandlingRequirements(jurisdiction)
    };
    
    // Auto-generate required reports
    if (overallCompliance.compliant) {
      await this.generateRequiredReports(transaction, overallCompliance.required_reports);
    }
    
    return overallCompliance;
  }
  
  // MiFID II transaction reporting
  async generateMiFIDTransactionReport(transaction) {
    const report = {
      reportingTimestamp: new Date().toISOString(),
      transactionReferenceNumber: transaction.id,
      tradingVenue: transaction.venue,
      instrumentIdentification: {
        isin: transaction.instrument.isin,
        lei: transaction.instrument.lei
      },
      buyerIdentification: {
        lei: transaction.buyer.lei,
        countryCode: transaction.buyer.country
      },
      sellerIdentification: {
        lei: transaction.seller.lei,
        countryCode: transaction.seller.country
      },
      transactionDetails: {
        price: transaction.price,
        quantity: transaction.quantity,
        currency: transaction.currency,
        executionDateTime: transaction.executionTime
      },
      flags: {
        commodityDerivative: transaction.flags.commodityDerivative,
        securitiesFinancingTransaction: transaction.flags.sft,
        postTradeDeferral: transaction.flags.postTradeDeferral
      }
    };
    
    // Validate report against ESMA schema
    await this.validateReportSchema(report, 'MIFID_II');
    
    // Submit to approved reporting mechanism (ARM)
    await this.submitToARM(report);
    
    return report;
  }
  
  // GDPR consent management
  async manageGDPRConsent(userId, jurisdiction) {
    if (!this.jurisdictions.get(jurisdiction).consentRequired) {
      return { consentRequired: false };
    }
    
    const consentManager = new GDPRConsentManager();
    
    const currentConsent = await consentManager.getConsent(userId);
    
    if (!currentConsent || this.isConsentExpired(currentConsent)) {
      // Request new consent
      const consentRequest = await consentManager.requestConsent(userId, {
        purposes: ['trading_execution', 'risk_management', 'regulatory_reporting'],
        dataTypes: ['personal_data', 'financial_data', 'transaction_data'],
        retention: '7_years',
        lawfulBasis: 'legitimate_interest'
      });
      
      return { 
        consentRequired: true, 
        consentRequest,
        status: 'pending'
      };
    }
    
    return { 
      consentRequired: true, 
      consent: currentConsent,
      status: 'valid'
    };
  }
  
  // Automated compliance monitoring
  async runComplianceChecks() {
    const complianceReport = {
      timestamp: new Date().toISOString(),
      checks: []
    };
    
    // Check all active jurisdictions
    for (const [jurisdiction, config] of this.jurisdictions) {
      for (const regulation of config.regulations) {
        const checker = this.getComplianceChecker(regulation);
        const result = await checker.runDailyChecks();
        
        complianceReport.checks.push({
          jurisdiction,
          regulation,
          status: result.compliant ? 'PASS' : 'FAIL',
          issues: result.issues || [],
          recommendations: result.recommendations || []
        });
      }
    }
    
    // Generate alerts for failures
    const failures = complianceReport.checks.filter(c => c.status === 'FAIL');
    if (failures.length > 0) {
      await this.sendComplianceAlert(failures);
    }
    
    // Store compliance report
    await this.storeComplianceReport(complianceReport);
    
    return complianceReport;
  }
}
```

**5.2.7** Secrets Management & Certificate Automation
```yaml
# HashiCorp Vault integration for secrets management
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-config
  namespace: trading-system
data:
  vault-config.hcl: |
    # Vault configuration
    ui = true
    cluster_name = "trading-vault-cluster"
    
    storage "consul" {
      address = "consul:8500"
      path    = "vault/"
    }
    
    # API listener
    listener "tcp" {
      address       = "0.0.0.0:8200"
      tls_cert_file = "/vault/tls/vault.crt"
      tls_key_file  = "/vault/tls/vault.key"
    }
    
    # Seal configuration - AWS KMS
    seal "awskms" {
      region     = "us-east-1"
      kms_key_id = "vault-unseal-key"
    }
    
    # Enable audit logging
    audit_device "file" {
      file_path = "/vault/logs/audit.log"
    }

---
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-secret-store
  namespace: trading-system
spec:
  provider:
    vault:
      server: "https://vault.trading-system.local:8200"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "trading-system"

---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: trading-secrets
  namespace: trading-system
spec:
  refreshInterval: 300s
  secretStoreRef:
    name: vault-secret-store
    kind: SecretStore
    
  target:
    name: trading-system-secrets
    creationPolicy: Owner
    
  data:
  - secretKey: alpha-vantage-api-key
    remoteRef:
      key: apis/alpha-vantage
      property: api-key
      
  - secretKey: database-password
    remoteRef:
      key: database/postgres
      property: password
      
  - secretKey: jwt-secret
    remoteRef:
      key: auth/jwt
      property: secret
      
  - secretKey: encryption-key
    remoteRef:
      key: encryption/master
      property: key

---
# Certificate management with cert-manager
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: devops@trading-system.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
          podTemplate:
            spec:
              nodeSelector:
                "kubernetes.io/os": linux

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: trading-system-tls
  namespace: trading-system
spec:
  secretName: trading-system-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - trading.yourdomain.com
  - api.trading.yourdomain.com
  - ws.trading.yourdomain.com
```

---

## **🏢 TAREA 3: Multi-tenant Architecture & Enterprise Features**
*Duración estimada: 1.5 semanas*
*Aplicando Sandro Mancuso's craftsmanship principles + enterprise software architecture patterns*

### **Subtareas (5 items):**

**5.3.1** Multi-tenant Data Isolation Strategy
```javascript
// Tenant isolation siguiendo enterprise SaaS patterns
class MultiTenantDataManager {
  constructor() {
    this.isolationStrategy = process.env.TENANT_ISOLATION || 'schema_per_tenant';
    this.tenantRegistry = new TenantRegistry();
    this.setupIsolationStrategy();
  }
  
  setupIsolationStrategy() {
    this.isolationStrategies = {
      // Database per tenant - highest isolation
      database_per_tenant: new DatabasePerTenantStrategy(),
      
      // Schema per tenant - balanced approach
      schema_per_tenant: new SchemaPerTenantStrategy(),
      
      // Row-level security - most efficient
      row_level_security: new RowLevelSecurityStrategy()
    };
    
    this.currentStrategy = this.isolationStrategies[this.isolationStrategy];
  }
  
  async provisionTenant(tenantConfig) {
    const tenantId = this.generateTenantId();
    
    // Create tenant record
    const tenant = {
      id: tenantId,
      name: tenantConfig.name,
      domain: tenantConfig.domain,
      plan: tenantConfig.plan,
      features: this.getPlanFeatures(tenantConfig.plan),
      limits: this.getPlanLimits(tenantConfig.plan),
      created_at: new Date().toISOString(),
      status: 'provisioning'
    };
    
    try {
      // Provision data isolation
      await this.currentStrategy.provisionTenant(tenant);
      
      // Setup tenant-specific configurations
      await this.setupTenantConfiguration(tenant);
      
      // Initialize tenant data
      await this.initializeTenantData(tenant);
      
      // Setup monitoring
      await this.setupTenantMonitoring(tenant);
      
      tenant.status = 'active';
      await this.tenantRegistry.updateTenant(tenantId, tenant);
      
      return tenant;
      
    } catch (error) {
      tenant.status = 'failed';
      await this.tenantRegistry.updateTenant(tenantId, tenant);
      throw error;
    }
  }
  
  getPlanFeatures(plan) {
    const planFeatures = {
      basic: [
        'market_data_access',
        'basic_charting',
        'order_execution',
        'basic_alerts'
      ],
      
      professional: [
        'market_data_access',
        'advanced_charting',
        'order_execution',
        'advanced_alerts',
        'technical_analysis',
        'api_access'
      ],
      
      enterprise: [
        'market_data_access',
        'advanced_charting',
        'order_execution',
        'advanced_alerts',
        'technical_analysis',
        'api_access',
        'ml_predictions',
        'custom_integrations',
        'white_labeling',
        'dedicated_support'
      ]
    };
    
    return planFeatures[plan] || planFeatures.basic;
  }
  
  getPlanLimits(plan) {
    const planLimits = {
      basic: {
        max_users: 5,
        max_orders_per_day: 100,
        max_api_calls_per_hour: 1000,
        data_retention_days: 90,
        support_level: 'community'
      },
      
      professional: {
        max_users: 50,
        max_orders_per_day: 1000,
        max_api_calls_per_hour: 10000,
        data_retention_days: 365,
        support_level: 'email'
      },
      
      enterprise: {
        max_users: 'unlimited',
        max_orders_per_day: 'unlimited',
        max_api_calls_per_hour: 100000,
        data_retention_days: 2555, // 7 years
        support_level: 'dedicated'
      }
    };
    
    return planLimits[plan] || planLimits.basic;
  }
}

// Schema per tenant implementation
class SchemaPerTenantStrategy {
  constructor() {
    this.masterConnection = new DatabaseConnection(process.env.MASTER_DB_URL);
  }
  
  async provisionTenant(tenant) {
    const schemaName = `tenant_${tenant.id}`;
    
    // Create dedicated schema
    await this.masterConnection.query(`CREATE SCHEMA IF NOT EXISTS ${schemaName}`);
    
    // Create tenant-specific tables
    await this.createTenantTables(schemaName);
    
    // Setup schema-level permissions
    await this.setupSchemaPermissions(schemaName, tenant);
    
    // Create tenant-specific connection pool
    await this.createTenantConnectionPool(tenant.id, schemaName);
    
    tenant.database_schema = schemaName;
  }
  
  async createTenantTables(schemaName) {
    const tables = [
      'users', 'trading_accounts', 'orders', 'positions', 
      'transactions', 'market_data_subscriptions', 'alerts',
      'user_preferences', 'api_keys', 'audit_logs'
    ];
    
    for (const table of tables) {
      const tableSchema = this.getTableSchema(table);
      await this.masterConnection.query(
        `CREATE TABLE ${schemaName}.${table} (${tableSchema})`
      );
    }
    
    // Create indexes
    await this.createTenantIndexes(schemaName);
  }
  
  async getTenantConnection(tenantId) {
    const tenant = await this.tenantRegistry.getTenant(tenantId);
    const connectionPool = this.tenantConnections.get(tenantId);
    
    if (!connectionPool) {
      throw new Error(`No connection pool for tenant ${tenantId}`);
    }
    
    const connection = await connectionPool.getConnection();
    
    // Set schema context
    await connection.query(`SET search_path TO ${tenant.database_schema}`);
    
    return connection;
  }
}

// Tenant context middleware
class TenantContextMiddleware {
  constructor() {
    this.tenantResolver = new TenantResolver();
    this.tenantRegistry = new TenantRegistry();
  }
  
  middleware() {
    return async (req, res, next) => {
      try {
        // Resolve tenant from request
        const tenantId = await this.tenantResolver.resolve(req);
        
        if (!tenantId) {
          return res.status(400).json({ error: 'Tenant identification required' });
        }
        
        // Get tenant configuration
        const tenant = await this.tenantRegistry.getTenant(tenantId);
        
        if (!tenant || tenant.status !== 'active') {
          return res.status(404).json({ error: 'Tenant not found or inactive' });
        }
        
        // Check feature access
        const requestedFeature = this.extractFeatureFromRequest(req);
        if (!this.checkFeatureAccess(tenant, requestedFeature)) {
          return res.status(403).json({ error: 'Feature not available in current plan' });
        }
        
        // Check rate limits
        await this.checkRateLimits(tenant, req);
        
        // Set tenant context
        req.tenant = tenant;
        req.tenantId = tenantId;
        
        next();
        
      } catch (error) {
        console.error('Tenant context error:', error);
        res.status(500).json({ error: 'Tenant context resolution failed' });
      }
    };
  }
  
  async checkRateLimits(tenant, req) {
    const limiter = new TenantRateLimiter(tenant.limits);
    
    const isAllowed = await limiter.checkLimit(tenant.id, {
      endpoint: req.path,
      method: req.method,
      user: req.user?.id
    });
    
    if (!isAllowed) {
      throw new RateLimitError('Tenant rate limit exceeded');
    }
  }
}
```

**5.3.2** Feature Flag Management System
```javascript
// Enterprise feature flagging siguiendo Martin Fowler's feature toggle patterns
class EnterpriseFeatureFlagManager {
  constructor() {
    this.flagStore = new FeatureFlagStore();
    this.evaluationEngine = new FeatureFlagEvaluationEngine();
    this.auditLogger = new FeatureFlagAuditLogger();
    this.setupFeatureFlags();
  }
  
  setupFeatureFlags() {
    // Trading features
    this.registerFlag('advanced_charting', {
      type: 'plan_based',
      description: 'Advanced charting with custom indicators',
      plans: ['professional', 'enterprise'],
      rollout: {
        strategy: 'gradual',
        percentage: 100
      }
    });
    
    this.registerFlag('ml_predictions', {
      type: 'plan_based',
      description: 'Machine learning price predictions',
      plans: ['enterprise'],
      rollout: {
        strategy: 'beta',
        percentage: 50,
        beta_users: ['tenant_123', 'tenant_456']
      }
    });
    
    this.registerFlag('api_v2', {
      type: 'experiment',
      description: 'New API version with enhanced performance',
      rollout: {
        strategy: 'a_b_test',
        percentage: 25,
        control_group: 'api_v1',
        experiment_group: 'api_v2'
      }
    });
    
    this.registerFlag('dark_mode', {
      type: 'user_preference',
      description: 'Dark mode UI theme',
      rollout: {
        strategy: 'opt_in',
        percentage: 100
      }
    });
    
    // Infrastructure features
    this.registerFlag('redis_cluster', {
      type: 'infrastructure',
      description: 'Use Redis cluster for caching',
      rollout: {
        strategy: 'blue_green',
        percentage: 0 // Start disabled
      }
    });
  }
  
  async evaluateFlag(flagName, context) {
    const flag = await this.flagStore.getFlag(flagName);
    
    if (!flag || !flag.enabled) {
      return { enabled: false, variant: 'control' };
    }
    
    const evaluation = await this.evaluationEngine.evaluate(flag, context);
    
    // Log evaluation for audit
    await this.auditLogger.logEvaluation({
      flag_name: flagName,
      context,
      result: evaluation,
      timestamp: new Date().toISOString()
    });
    
    return evaluation;
  }
  
  async evaluateUserFlags(userId, tenantId, userPlan) {
    const context = {
      user_id: userId,
      tenant_id: tenantId,
      plan: userPlan,
      timestamp: new Date().toISOString()
    };
    
    const allFlags = await this.flagStore.getAllFlags();
    const evaluations = {};
    
    for (const [flagName, flag] of allFlags) {
      evaluations[flagName] = await this.evaluateFlag(flagName, context);
    }
    
    return evaluations;
  }
  
  // A/B testing framework
  async assignExperimentVariant(flagName, context) {
    const flag = await this.flagStore.getFlag(flagName);
    
    if (flag.type !== 'experiment') {
      throw new Error('Flag is not an experiment');
    }
    
    const variantAssigner = new ExperimentVariantAssigner();
    const assignment = await variantAssigner.assign(flag, context);
    
    // Store assignment for consistency
    await this.storeAssignment(flagName, context.user_id, assignment);
    
    return assignment;
  }
  
  // Gradual rollout management
  async updateRolloutPercentage(flagName, newPercentage) {
    const flag = await this.flagStore.getFlag(flagName);
    
    // Validate rollout strategy
    if (!this.canUpdateRollout(flag, newPercentage)) {
      throw new Error('Invalid rollout update');
    }
    
    // Update flag configuration
    flag.rollout.percentage = newPercentage;
    await this.flagStore.updateFlag(flagName, flag);
    
    // Log rollout change
    await this.auditLogger.logRolloutChange({
      flag_name: flagName,
      old_percentage: flag.rollout.percentage,
      new_percentage: newPercentage,
      timestamp: new Date().toISOString()
    });
    
    // Notify monitoring system
    await this.notifyRolloutChange(flagName, newPercentage);
  }
  
  // Feature flag middleware
  requireFeature(flagName) {
    return async (req, res, next) => {
      const context = {
        user_id: req.user?.id,
        tenant_id: req.tenantId,
        plan: req.tenant?.plan,
        ip_address: req.ip
      };
      
      const evaluation = await this.evaluateFlag(flagName, context);
      
      if (!evaluation.enabled) {
        return res.status(403).json({
          error: 'Feature not available',
          feature: flagName
        });
      }
      
      req.featureVariant = evaluation.variant;
      next();
    };
  }
}

// Feature flag evaluation engine
class FeatureFlagEvaluationEngine {
  async evaluate(flag, context) {
    switch (flag.rollout.strategy) {
      case 'gradual':
        return this.evaluateGradualRollout(flag, context);
        
      case 'beta':
        return this.evaluateBetaRollout(flag, context);
        
      case 'a_b_test':
        return this.evaluateABTest(flag, context);
        
      case 'plan_based':
        return this.evaluatePlanBased(flag, context);
        
      case 'user_preference':
        return this.evaluateUserPreference(flag, context);
        
      default:
        return { enabled: false, variant: 'control' };
    }
  }
  
  evaluateGradualRollout(flag, context) {
    const hash = this.hashContext(context.user_id || context.tenant_id);
    const bucket = hash % 100;
    
    const enabled = bucket < flag.rollout.percentage;
    
    return {
      enabled,
      variant: enabled ? 'treatment' : 'control',
      bucket
    };
  }
  
  evaluatePlanBased(flag, context) {
    const enabled = flag.plans.includes(context.plan);
    
    return {
      enabled,
      variant: enabled ? 'treatment' : 'control',
      reason: enabled ? 'plan_included' : 'plan_not_included'
    };
  }
  
  evaluateABTest(flag, context) {
    const hash = this.hashContext(context.user_id);
    const bucket = hash % 100;
    
    let variant = 'control';
    if (bucket < flag.rollout.percentage) {
      variant = 'treatment';
    }
    
    return {
      enabled: true,
      variant,
      bucket,
      experiment: true
    };
  }
  
  hashContext(input) {
    // Simple hash function for consistent bucketing
    let hash = 0;
    for (let i = 0; i < input.length; i++) {
      const char = input.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return Math.abs(hash);
  }
}
```

**5.3.3** Enterprise SSO & Directory Integration
```javascript
// SAML 2.0 + LDAP integration siguiendo enterprise identity standards
class EnterpriseSSOManager {
  constructor() {
    this.samlProvider = new SAML2Provider();
    this.ldapClient = new LDAPClient();
    this.oidcProvider = new OIDCProvider();
    this.setupSSOProviders();
  }
  
  setupSSOProviders() {
    // SAML configuration for enterprise customers
    this.samlProvider.configure({
      entryPoint: process.env.SAML_ENTRY_POINT,
      issuer: 'trading-system',
      cert: process.env.SAML_CERT,
      identifierFormat: 'urn:oasis:names:tc:SAML:2.0:nameid-format:emailAddress',
      signatureAlgorithm: 'sha256',
      digestAlgorithm: 'sha256',
      attributeConsumingServiceIndex: false,
      disableRequestedAuthnContext: false,
      authnContext: [
        'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport',
        'urn:oasis:names:tc:SAML:2.0:ac:classes:Password'
      ]
    });
    
    // LDAP configuration for Active Directory
    this.ldapClient.configure({
      url: process.env.LDAP_URL,
      baseDN: process.env.LDAP_BASE_DN,
      username: process.env.LDAP_BIND_USER,
      password: process.env.LDAP_BIND_PASSWORD,
      searchFilter: '(&(objectClass=user)(sAMAccountName={{username}}))',
      attributes: ['cn', 'mail', 'memberOf', 'department', 'title']
    });
  }
  
  async initiateSAMLLogin(tenantId, req, res) {
    const tenant = await this.getTenantSSOConfig(tenantId);
    
    if (!tenant.sso_enabled || tenant.sso_provider !== 'saml') {
      throw new Error('SAML SSO not configured for tenant');
    }
    
    // Generate SAML request
    const samlRequest = this.samlProvider.generateLoginRequest({
      entryPoint: tenant.saml_config.entry_point,
      issuer: tenant.saml_config.issuer,
      callbackUrl: `${process.env.BASE_URL}/auth/saml/callback/${tenantId}`
    });
    
    // Store request state
    await this.storeSAMLState(samlRequest.id, {
      tenant_id: tenantId,
      initiated_at: new Date().toISOString(),
      ip_address: req.ip,
      user_agent: req.get('User-Agent')
    });
    
    // Redirect to IdP
    res.redirect(samlRequest.loginUrl);
  }
  
  async handleSAMLCallback(tenantId, samlResponse, req) {
    const tenant = await this.getTenantSSOConfig(tenantId);
    
    // Validate SAML response
    const validation = await this.samlProvider.validateResponse(samlResponse, {
      cert: tenant.saml_config.cert,
      issuer: tenant.saml_config.issuer
    });
    
    if (!validation.valid) {
      throw new SAMLValidationError('Invalid SAML response');
    }
    
    // Extract user attributes
    const userAttributes = this.extractSAMLAttributes(validation.attributes);
    
    // Map to internal user format
    const user = await this.mapSAMLUser(userAttributes, tenantId);
    
    // Create or update user
    const authenticatedUser = await this.provisionSSOUser(user, tenantId);
    
    // Generate internal session
    const session = await this.createUserSession(authenticatedUser, {
      sso_provider: 'saml',
      idp_session_id: validation.sessionId,
      tenant_id: tenantId
    });
    
    return { user: authenticatedUser, session };
  }
  
  async authenticateLDAP(username, password, tenantId) {
    const tenant = await this.getTenantSSOConfig(tenantId);
    
    if (!tenant.ldap_enabled) {
      throw new Error('LDAP authentication not enabled for tenant');
    }
    
    try {
      // Bind with service account
      await this.ldapClient.bind(
        tenant.ldap_config.bind_user,
        tenant.ldap_config.bind_password
      );
      
      // Search for user
      const searchFilter = tenant.ldap_config.search_filter.replace('{{username}}', username);
      const searchResults = await this.ldapClient.search(tenant.ldap_config.base_dn, {
        filter: searchFilter,
        scope: 'sub',
        attributes: tenant.ldap_config.attributes
      });
      
      if (searchResults.length === 0) {
        throw new AuthenticationError('User not found in LDAP');
      }
      
      const userDN = searchResults[0].dn;
      
      // Authenticate user
      await this.ldapClient.bind(userDN, password);
      
      // Map LDAP attributes to user
      const user = await this.mapLDAPUser(searchResults[0], tenantId);
      
      // Provision or update user
      const authenticatedUser = await this.provisionSSOUser(user, tenantId);
      
      return authenticatedUser;
      
    } catch (error) {
      if (error.name === 'InvalidCredentialsError') {
        throw new AuthenticationError('Invalid credentials');
      }
      throw error;
    } finally {
      await this.ldapClient.unbind();
    }
  }
  
  async mapSAMLUser(attributes, tenantId) {
    const roleMapping = await this.getTenantRoleMapping(tenantId);
    
    return {
      email: attributes.email || attributes['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'],
      first_name: attributes.first_name || attributes['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname'],
      last_name: attributes.last_name || attributes['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname'],
      department: attributes.department,
      title: attributes.title,
      roles: this.mapAttributesToRoles(attributes.groups, roleMapping),
      sso_id: attributes.name_id,
      tenant_id: tenantId,
      authentication_method: 'saml'
    };
  }
  
  async mapLDAPUser(ldapEntry, tenantId) {
    const roleMapping = await this.getTenantRoleMapping(tenantId);
    
    return {
      email: ldapEntry.mail,
      first_name: this.extractFirstName(ldapEntry.cn),
      last_name: this.extractLastName(ldapEntry.cn),
      department: ldapEntry.department,
      title: ldapEntry.title,
      roles: this.mapAttributesToRoles(ldapEntry.memberOf, roleMapping),
      sso_id: ldapEntry.sAMAccountName,
      tenant_id: tenantId,
      authentication_method: 'ldap'
    };
  }
  
  async provisionSSOUser(userData, tenantId) {
    const userManager = new TenantUserManager(tenantId);
    
    // Check if user exists
    let user = await userManager.findBySSOId(userData.sso_id);
    
    if (user) {
      // Update existing user
      user = await userManager.update(user.id, {
        email: userData.email,
        first_name: userData.first_name,
        last_name: userData.last_name,
        department: userData.department,
        title: userData.title,
        roles: userData.roles,
        last_login: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
    } else {
      // Create new user
      user = await userManager.create({
        ...userData,
        status: 'active',
        created_at: new Date().toISOString(),
        email_verified: true // SSO users are pre-verified
      });
    }
    
    // Sync user permissions
    await this.syncUserPermissions(user, tenantId);
    
    // Log SSO authentication
    await this.logSSOAuthentication(user, userData.authentication_method);
    
    return user;
  }
  
  // Group-to-role mapping
  mapAttributesToRoles(groups, roleMapping) {
    const roles = [];
    
    if (!groups || !roleMapping) {
      return ['viewer']; // Default role
    }
    
    // Convert single group to array
    const groupList = Array.isArray(groups) ? groups : [groups];
    
    for (const group of groupList) {
      const mappedRole = roleMapping[group];
      if (mappedRole && !roles.includes(mappedRole)) {
        roles.push(mappedRole);
      }
    }
    
    return roles.length > 0 ? roles : ['viewer'];
  }
  
  // Session management for SSO users
  async createUserSession(user, ssoContext) {
    const sessionManager = new SessionManager();
    
    const session = await sessionManager.create({
      user_id: user.id,
      tenant_id: user.tenant_id,
      authentication_method: ssoContext.sso_provider,
      sso_session_id: ssoContext.idp_session_id,
      ip_address: ssoContext.ip_address,
      user_agent: ssoContext.user_agent,
      expires_at: new Date(Date.now() + 8 * 60 * 60 * 1000), // 8 hours
      created_at: new Date().toISOString()
    });
    
    return session;
  }
}

// Just-in-time (JIT) user provisioning
class JITUserProvisioning {
  constructor() {
    this.userTemplates = new Map();
    this.provisioningRules = new Map();
  }
  
  async provisionUser(ssoUserData, tenantId) {
    const template = await this.getUserTemplate(tenantId, ssoUserData.department);
    const rules = await this.getProvisioningRules(tenantId);
    
    // Apply provisioning rules
    const userData = {
      ...ssoUserData,
      ...template.defaults,
      permissions: this.calculatePermissions(ssoUserData, rules),
      trading_limits: this.calculateTradingLimits(ssoUserData, rules),
      features: this.calculateFeatureAccess(ssoUserData, rules)
    };
    
    // Create user account
    const user = await this.createUserAccount(userData, tenantId);
    
    // Setup initial data
    await this.setupUserInitialData(user);
    
    // Send welcome notification
    await this.sendWelcomeNotification(user);
    
    return user;
  }
}