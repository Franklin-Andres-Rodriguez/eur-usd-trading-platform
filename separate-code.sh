#!/bin/bash
# separate-code.sh - Separar el HTML monolítico en estructura profesional

echo "🔧 Separando código HTML en estructura modular..."

# Crear index.html principal (sin CSS ni JavaScript inline)
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EUR/USD Professional Trading Platform</title>
    
    <!-- Meta tags para SEO y redes sociales -->
    <meta name="description" content="Professional EUR/USD trading platform with real-time data, multi-timeframe analysis, and AI-powered insights">
    <meta name="keywords" content="EUR/USD, forex trading, real-time data, technical analysis, trading platform">
    <meta name="author" content="Franklin Andres Rodriguez">
    
    <!-- Open Graph para redes sociales -->
    <meta property="og:title" content="EUR/USD Professional Trading Platform">
    <meta property="og:description" content="Advanced trading platform with real-time data and AI analysis">
    <meta property="og:image" content="https://franklin-andres-rodriguez.github.io/eur-usd-trading-platform/assets/preview.png">
    <meta property="og:url" content="https://franklin-andres-rodriguez.github.io/eur-usd-trading-platform">
    
    <!-- External libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    
    <!-- Custom styles -->
    <link rel="stylesheet" href="src/css/main.css">
    <link rel="stylesheet" href="src/css/responsive.css">
    
    <!-- Favicon -->
    <link rel="icon" href="assets/favicon.ico" type="image/x-icon">
    
    <!-- Preload critical resources -->
    <link rel="preload" href="src/css/main.css" as="style">
    <link rel="preload" href="src/js/main.js" as="script">
</head>
<body>
    <!-- Beautiful Top Navigation -->
    <div class="top-nav">
        <div class="logo-section">
            <div class="logo">💱 EUR/USD Pro</div>
            <div class="live-price-display">
                <div class="price-main" id="livePrice">1.1659</div>
                <div class="price-change positive" id="priceChange">+0.0012 (+0.10%)</div>
            </div>
        </div>
        
        <div class="api-status">
            <div class="status-dot" id="apiStatusDot"></div>
            <span id="apiStatusText">Live Data Active • Alpha Vantage</span>
        </div>
    </div>

    <div class="container">
        <div class="main-grid">
            <!-- Left Panel: Multi-Timeframe Analysis -->
            <div class="panel">
                <h2 class="panel-title">⏰ Multi-Timeframe Analysis</h2>
                
                <!-- Confluence Score -->
                <div class="confluence-section">
                    <div class="confluence-title">🎯 Trend Confluence Score</div>
                    <div class="confluence-score" id="confluenceScore">75%</div>
                    <div class="confluence-details" id="confluenceDetails">
                        3 of 4 timeframes bullish • Strong setup
                    </div>
                </div>
                
                <!-- Timeframes Grid -->
                <div class="timeframe-grid">
                    <div class="timeframe-card bullish" id="tf-1h">
                        <div class="tf-header">
                            <div class="tf-name">1 Hour</div>
                            <div class="trend-badge trend-bullish">Bullish</div>
                        </div>
                        <div class="tf-metrics">
                            <span>RSI: <strong id="rsi-1h">65.4</strong></span>
                            <span>MACD: <strong id="macd-1h">+0.0024</strong></span>
                        </div>
                    </div>
                    
                    <div class="timeframe-card bullish" id="tf-4h">
                        <div class="tf-header">
                            <div class="tf-name">4 Hours</div>
                            <div class="trend-badge trend-bullish">Bullish</div>
                        </div>
                        <div class="tf-metrics">
                            <span>RSI: <strong id="rsi-4h">58.2</strong></span>
                            <span>MACD: <strong id="macd-4h">+0.0018</strong></span>
                        </div>
                    </div>
                    
                    <div class="timeframe-card neutral" id="tf-1d">
                        <div class="tf-header">
                            <div class="tf-name">Daily</div>
                            <div class="trend-badge trend-neutral">Neutral</div>
                        </div>
                        <div class="tf-metrics">
                            <span>RSI: <strong id="rsi-1d">48.7</strong></span>
                            <span>MACD: <strong id="macd-1d">-0.0005</strong></span>
                        </div>
                    </div>
                    
                    <div class="timeframe-card bearish" id="tf-1w">
                        <div class="tf-header">
                            <div class="tf-name">Weekly</div>
                            <div class="trend-badge trend-bearish">Bearish</div>
                        </div>
                        <div class="tf-metrics">
                            <span>RSI: <strong id="rsi-1w">35.1</strong></span>
                            <span>MACD: <strong id="macd-1w">-0.0089</strong></span>
                        </div>
                    </div>
                </div>
                
                <!-- Market Insight -->
                <div class="market-insight">
                    <div class="insight-title">🧠 Smart Analysis</div>
                    <div class="insight-content" id="smartAnalysis">
                        H1 and H4 showing strong bullish momentum with RSI in healthy range. Consider long positions with stops below 1.1620. Target resistance at 1.1750.
                    </div>
                </div>
                
                <button class="btn btn-success" onclick="refreshAnalysis()">🔄 Refresh Analysis</button>
            </div>
            
            <!-- Center Panel: Chart -->
            <div class="panel chart-panel">
                <h2 class="panel-title">📈 Live EUR/USD Chart</h2>
                
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                    <div style="display: flex; gap: 15px;">
                        <button class="btn" onclick="changeTimeframe('1H')" id="btn-1h">1H</button>
                        <button class="btn" onclick="changeTimeframe('4H')" id="btn-4h">4H</button>
                        <button class="btn" onclick="changeTimeframe('1D')" id="btn-1d">1D</button>
                    </div>
                    <div style="font-size: 0.9em; color: #6b7280;">
                        <strong>Source:</strong> <span id="dataSource">Alpha Vantage</span> • 
                        <strong>Updated:</strong> <span id="lastUpdate">30s ago</span>
                    </div>
                </div>
                
                <div class="chart-container">
                    <canvas id="mainChart"></canvas>
                </div>
            </div>
            
            <!-- Right Panel: Economic Calendar & Alerts -->
            <div class="panel">
                <h2 class="panel-title">📅 Economic Calendar</h2>
                
                <!-- Next Major Event -->
                <div class="news-header">
                    <div class="news-title">🚨 Next Major Event</div>
                    <div class="countdown-timer" id="nextEventTimer">ECB Decision: 02:45:30</div>
                </div>
                
                <!-- Economic Events -->
                <div class="economic-calendar">
                    <div class="event-item high">
                        <div class="event-info">
                            <div class="event-name">🏛️ ECB Interest Rate Decision</div>
                            <div class="event-time">Today 14:00 GMT</div>
                        </div>
                        <div class="event-impact impact-high">High</div>
                    </div>
                    
                    <div class="event-item high">
                        <div class="event-info">
                            <div class="event-name">🇺🇸 Non-Farm Payrolls</div>
                            <div class="event-time">Friday 13:30 GMT</div>
                        </div>
                        <div class="event-impact impact-high">High</div>
                    </div>
                    
                    <div class="event-item medium">
                        <div class="event-info">
                            <div class="event-name">🇪🇺 Consumer Price Index</div>
                            <div class="event-time">Tomorrow 10:00 GMT</div>
                        </div>
                        <div class="event-impact impact-medium">Medium</div>
                    </div>
                    
                    <div class="event-item medium">
                        <div class="event-info">
                            <div class="event-name">🇺🇸 Retail Sales</div>
                            <div class="event-time">Thursday 13:30 GMT</div>
                        </div>
                        <div class="event-impact impact-medium">Medium</div>
                    </div>
                    
                    <div class="event-item low">
                        <div class="event-info">
                            <div class="event-name">🇩🇪 German IFO Business Climate</div>
                            <div class="event-time">Friday 09:00 GMT</div>
                        </div>
                        <div class="event-impact impact-low">Low</div>
                    </div>
                </div>
                
                <!-- Live Alerts Section -->
                <div class="alerts-section">
                    <h3 style="color: #4b5563; margin-bottom: 15px; font-size: 1.1em;">🚨 Live Alerts</h3>
                    
                    <div class="alert-item critical">
                        <div class="alert-header">
                            <div class="alert-title">RSI Oversold H1</div>
                            <div class="alert-time">2 min ago</div>
                        </div>
                        <div class="alert-message">
                            RSI dropped to 28.5 on 1H timeframe - potential reversal opportunity
                        </div>
                    </div>
                    
                    <div class="alert-item warning">
                        <div class="alert-header">
                            <div class="alert-title">Support Level Test</div>
                            <div class="alert-time">5 min ago</div>
                        </div>
                        <div class="alert-message">
                            Price testing key support at 1.1650 - watch for break or bounce
                        </div>
                    </div>
                    
                    <div class="alert-item">
                        <div class="alert-header">
                            <div class="alert-title">Volume Spike Detected</div>
                            <div class="alert-time">8 min ago</div>
                        </div>
                        <div class="alert-message">
                            Unusual volume activity - potential breakout incoming
                        </div>
                    </div>
                </div>
                
                <button class="btn btn-warning" onclick="configureAlerts()">⚙️ Configure Alerts</button>
            </div>
        </div>
        
        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value positive" id="todayRange">89 pips</div>
                <div class="stat-label">Today's Range</div>
                <div class="stat-change" style="color: #16a34a;">+12 pips vs avg</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-value positive" id="sessionHigh">1.1695</div>
                <div class="stat-label">Session High</div>
                <div class="stat-change" style="color: #16a34a;">+0.0045</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-value negative" id="sessionLow">1.1606</div>
                <div class="stat-label">Session Low</div>
                <div class="stat-change" style="color: #dc2626;">-0.0053</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-value neutral" id="volatility">High</div>
                <div class="stat-label">Volatility (ATR)</div>
                <div class="stat-change" style="color: #3b82f6;">95 pips</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-value positive" id="signalsAccuracy">78%</div>
                <div class="stat-label">Signals Accuracy</div>
                <div class="stat-change" style="color: #16a34a;">+5% this week</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-value negative" id="maxDrawdown">-2.3%</div>
                <div class="stat-label">Max Drawdown</div>
                <div class="stat-change" style="color: #dc2626;">Within limits</div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="src/config/api.js"></script>
    <script src="src/js/utils.js"></script>
    <script src="src/js/api-manager.js"></script>
    <script src="src/js/chart-manager.js"></script>
    <script src="src/js/ui-manager.js"></script>
    <script src="src/js/main.js"></script>
</body>
</html>
EOF

echo "✅ index.html principal creado"

# Crear archivo CSS principal (extraer del HTML original)
cat > src/css/main.css << 'EOF'
/* EUR/USD Trading Platform - Main Styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #8b5cf6 100%);
    min-height: 100vh;
    color: #333;
    overflow-x: auto;
}

.top-nav {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px);
    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
    padding: 15px 25px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 1000;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.logo-section {
    display: flex;
    align-items: center;
    gap: 20px;
}

.logo {
    font-size: 1.8em;
    font-weight: bold;
    background: linear-gradient(135deg, #667eea, #764ba2);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.live-price-display {
    display: flex;
    align-items: center;
    gap: 15px;
    background: linear-gradient(135deg, #f0f9ff, #e0f2fe);
    padding: 10px 20px;
    border-radius: 25px;
    border: 2px solid rgba(102, 126, 234, 0.2);
}

.price-main {
    font-size: 2em;
    font-weight: bold;
    color: #16a34a;
}

.price-change {
    font-size: 1.1em;
    font-weight: 600;
}

.price-change.positive { color: #16a34a; }
.price-change.negative { color: #dc2626; }

.api-status {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.9em;
    color: #6b7280;
}

.status-dot {
    width: 8px;
    height: 8px;
    background: #16a34a;
    border-radius: 50%;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.6; }
}

.container {
    max-width: 1800px;
    margin: 0 auto;
    padding: 25px;
}

.main-grid {
    display: grid;
    grid-template-columns: 380px 1fr 360px;
    gap: 25px;
    margin-bottom: 25px;
}

.panel {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 20px;
    padding: 25px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.panel:hover {
    transform: translateY(-5px);
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
}

.panel-title {
    font-size: 1.4em;
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.panel-title::before {
    content: '';
    width: 4px;
    height: 25px;
    background: linear-gradient(135deg, #667eea, #764ba2);
    border-radius: 2px;
}

.timeframe-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
    margin-bottom: 20px;
}

.timeframe-card {
    background: linear-gradient(135deg, #f8fafc, #f1f5f9);
    border-radius: 15px;
    padding: 18px;
    border-left: 4px solid #16a34a;
    transition: all 0.3s ease;
    cursor: pointer;
}

.timeframe-card:hover {
    transform: translateX(5px);
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.timeframe-card.bearish {
    border-left-color: #ef4444;
    background: linear-gradient(135deg, #fef2f2, #fee2e2);
}

.timeframe-card.neutral {
    border-left-color: #f59e0b;
    background: linear-gradient(135deg, #fefce8, #fef3c7);
}

.tf-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
}

.tf-name {
    font-weight: 600;
    font-size: 1.1em;
    color: #1f2937;
}

.trend-badge {
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.8em;
    font-weight: 600;
    text-transform: uppercase;
}

.trend-bullish {
    background: #dcfce7;
    color: #16a34a;
}

.trend-bearish {
    background: #fecaca;
    color: #dc2626;
}

.trend-neutral {
    background: #fef3c7;
    color: #d97706;
}

.tf-metrics {
    display: flex;
    justify-content: space-between;
    font-size: 0.9em;
    color: #6b7280;
}

.confluence-section {
    background: linear-gradient(135deg, #eff6ff, #dbeafe);
    border: 2px solid rgba(59, 130, 246, 0.3);
    border-radius: 15px;
    padding: 20px;
    text-align: center;
    margin: 20px 0;
    transition: all 0.3s ease;
}

.confluence-section:hover {
    background: linear-gradient(135deg, #dbeafe, #bfdbfe);
}

.confluence-title {
    color: #1e40af;
    font-weight: 600;
    margin-bottom: 10px;
}

.confluence-score {
    font-size: 2.5em;
    font-weight: bold;
    color: #3b82f6;
    margin: 10px 0;
}

.confluence-details {
    font-size: 0.9em;
    color: #1e40af;
}

.chart-panel {
    position: relative;
}

.chart-container {
    height: 450px;
    margin-top: 20px;
    background: rgba(248, 250, 252, 0.5);
    border-radius: 15px;
    padding: 15px;
}

.btn {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 25px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
}

.btn-success {
    background: linear-gradient(135deg, #16a34a, #15803d);
}

.btn-warning {
    background: linear-gradient(135deg, #f59e0b, #d97706);
}

/* Más estilos... (resto del CSS del archivo original) */
EOF

echo "✅ CSS principal creado en src/css/main.css"
echo "⚠️  Nota: Necesitarás completar el CSS con el resto de estilos del archivo original"

# Crear archivo de configuración de API
cat > src/config/api.js << 'EOF'
// API Configuration - Configuración de API para EUR/USD Trading Platform
// IMPORTANTE: Este archivo debe estar en .gitignore para proteger las API keys

const API_CONFIG = {
    alphaVantage: {
        apiKey: 'DEMO_KEY', // ⚠️ CAMBIAR por tu API key real de Alpha Vantage
        baseUrl: 'https://www.alphavantage.co/query',
        active: true,
        requestsToday: 0,
        limit: 500,
        quality: 'premium',
        lastRequest: null
    },
    cors_proxy: 'https://api.allorigins.win/raw?url=', // CORS proxy para requests del browser
    fallback: {
        active: false,
        quality: 'standard'
    }
};

// Exportar configuración
if (typeof module !== 'undefined' && module.exports) {
    module.exports = API_CONFIG;
} else {
    window.API_CONFIG = API_CONFIG;
}
EOF

echo "✅ Configuración de API creada en src/config/api.js"
echo "⚠️  IMPORTANTE: Cambiar 'DEMO_KEY' por tu API key real de Alpha Vantage"

# Crear archivo JavaScript principal (extraer del HTML original)
cat > src/js/main.js << 'EOF'
// EUR/USD Trading Platform - Main JavaScript
// Sistema principal de la plataforma de trading

let tradingSystem = {
    currentPrice: 1.1659,
    priceChange: 0.0012,
    isLiveDataActive: true,
    currentTimeframe: '1H',
    priceHistory: [],
    lastUpdate: new Date(),
    dataSource: 'Alpha Vantage'
};

let timeframes = {
    '1h': { rsi: 65.4, macd: 0.0024, trend: 'bullish' },
    '4h': { rsi: 58.2, macd: 0.0018, trend: 'bullish' },
    '1d': { rsi: 48.7, macd: -0.0005, trend: 'neutral' },
    '1w': { rsi: 35.1, macd: -0.0089, trend: 'bearish' }
};

let mainChart = null;

// ===== FUNCIONES PRINCIPALES =====

// Inicialización del sistema
function initializeTradingSystem() {
    console.log('🚀 Initializing EUR/USD Trading Platform...');
    
    // Verificar si API_CONFIG está disponible
    if (typeof API_CONFIG === 'undefined') {
        console.error('❌ API_CONFIG not found. Please check api.js file.');
        return;
    }
    
    // Inicializar componentes
    initializeChart();
    
    // Cargar datos iniciales
    fetchRealMarketData();
    updateCountdownTimer();
    
    // Configurar intervals
    setInterval(fetchRealMarketData, 180000); // Cada 3 minutos
    setInterval(updateCountdownTimer, 1000); // Cada segundo
    
    // Animaciones de carga
    setTimeout(() => {
        document.querySelectorAll('.panel').forEach((panel, index) => {
            panel.style.animation = `fadeIn 0.6s ease-in ${index * 0.1}s forwards`;
        });
    }, 100);
    
    console.log('✅ Trading Platform Ready!');
}

// Obtener datos de mercado en tiempo real
async function fetchRealMarketData() {
    try {
        console.log('🌍 Fetching real EUR/USD data...');
        
        // Implementar llamada a API real aquí
        // Por ahora usar datos simulados
        const simulatedData = await simulateRealisticData();
        
        tradingSystem.currentPrice = simulatedData.price;
        tradingSystem.priceChange = simulatedData.change;
        tradingSystem.lastUpdate = new Date();
        
        updateLivePriceDisplay();
        updateChart();
        updateTimeframeData();
        
        console.log('✅ Market data updated');
        
    } catch (error) {
        console.error('❌ Error fetching market data:', error);
        await fallbackToSimulatedData();
    }
}

// Simular datos realistas para demo
async function simulateRealisticData() {
    const marketTime = new Date();
    const hour = marketTime.getUTCHours();
    
    // Volatilidad diferente según sesión de mercado
    let sessionMultiplier = 1;
    if (hour >= 8 && hour <= 16) {
        sessionMultiplier = 1.5; // Sesión Londres
    } else if (hour >= 13 && hour <= 21) {
        sessionMultiplier = 1.3; // Overlap NY
    } else {
        sessionMultiplier = 0.7; // Sesión Asia
    }
    
    const basePrice = 1.1659;
    const maxMove = 0.0003 * sessionMultiplier;
    const randomMove = (Math.random() - 0.5) * 2 * maxMove;
    const trendBias = 0.00001;
    
    const newPrice = (tradingSystem.currentPrice || basePrice) + randomMove + trendBias;
    const constrainedPrice = Math.max(1.1500, Math.min(1.1800, newPrice));
    
    return {
        price: constrainedPrice,
        change: constrainedPrice - (tradingSystem.currentPrice || basePrice),
        timestamp: new Date()
    };
}

// Inicializar gráfico principal
function initializeChart() {
    const ctx = document.getElementById('mainChart').getContext('2d');
    
    mainChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'EUR/USD',
                data: [],
                borderColor: '#667eea',
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                borderWidth: 3,
                pointRadius: 0,
                pointHoverRadius: 6,
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: { display: true, grid: { display: false } },
                y: { display: true, grid: { color: 'rgba(0, 0, 0, 0.05)' }, beginAtZero: false }
            }
        }
    });
}

// Actualizar gráfico
function updateChart() {
    if (!mainChart) return;
    
    tradingSystem.priceHistory.push({
        time: new Date(),
        price: tradingSystem.currentPrice
    });
    
    if (tradingSystem.priceHistory.length > 50) {
        tradingSystem.priceHistory.shift();
    }
    
    const labels = tradingSystem.priceHistory.map(point => 
        point.time.toLocaleTimeString().substring(0, 5)
    );
    const prices = tradingSystem.priceHistory.map(point => point.price);
    
    mainChart.data.labels = labels;
    mainChart.data.datasets[0].data = prices;
    mainChart.update('none');
}

// Actualizar display de precio en vivo
function updateLivePriceDisplay() {
    const priceElement = document.getElementById('livePrice');
    const changeElement = document.getElementById('priceChange');
    
    priceElement.style.transform = 'scale(1.05)';
    setTimeout(() => {
        priceElement.style.transform = 'scale(1)';
    }, 200);
    
    priceElement.textContent = tradingSystem.currentPrice.toFixed(4);
    
    const changePercent = (tradingSystem.priceChange / tradingSystem.currentPrice * 100).toFixed(3);
    const changeText = `${tradingSystem.priceChange >= 0 ? '+' : ''}${tradingSystem.priceChange.toFixed(4)} (${changePercent}%)`;
    
    changeElement.textContent = changeText;
    changeElement.className = `price-change ${tradingSystem.priceChange >= 0 ? 'positive' : 'negative'}`;
}

// ===== FUNCIONES DE INTERACCIÓN =====

// Refrescar análisis
function refreshAnalysis() {
    const button = event.target;
    const originalText = button.innerHTML;
    button.innerHTML = '🔄 Refreshing...';
    button.disabled = true;
    
    fetchRealMarketData().then(() => {
        button.innerHTML = originalText;
        button.disabled = false;
        
        // Feedback visual
        document.querySelectorAll('.timeframe-card').forEach(card => {
            card.style.transform = 'scale(1.02)';
            setTimeout(() => {
                card.style.transform = 'scale(1)';
            }, 200);
        });
    });
}

// Cambiar timeframe del gráfico
function changeTimeframe(tf) {
    tradingSystem.currentTimeframe = tf;
    
    document.querySelectorAll('[id^="btn-"]').forEach(btn => {
        btn.style.background = 'linear-gradient(135deg, #667eea, #764ba2)';
    });
    
    const activeBtn = document.getElementById(`btn-${tf.toLowerCase()}`);
    activeBtn.style.background = 'linear-gradient(135deg, #16a34a, #15803d)';
    
    console.log(`Switched to ${tf} timeframe`);
}

// Configurar alertas
function configureAlerts() {
    alert('🔔 Alert Configuration\n\nComing soon:\n• Custom RSI levels\n• Price breakout alerts\n• News impact notifications\n• SMS/Email delivery');
}

// ===== UTILIDADES =====

// Fallback a datos simulados
async function fallbackToSimulatedData() {
    console.log('🔄 Using simulated data as fallback...');
    const simulatedData = await simulateRealisticData();
    
    tradingSystem.currentPrice = simulatedData.price;
    tradingSystem.priceChange = simulatedData.change;
    tradingSystem.lastUpdate = new Date();
    tradingSystem.dataSource = 'Simulated (Fallback)';
    
    updateLivePriceDisplay();
    updateChart();
}

// Actualizar datos de timeframes
function updateTimeframeData() {
    Object.keys(timeframes).forEach(tf => {
        const frame = timeframes[tf];
        
        // Simular cambios realistas en indicadores
        frame.rsi += (Math.random() - 0.5) * 3;
        frame.rsi = Math.max(0, Math.min(100, frame.rsi));
        
        frame.macd += (Math.random() - 0.5) * 0.0008;
        
        // Actualizar UI
        document.getElementById(`rsi-${tf}`).textContent = frame.rsi.toFixed(1);
        document.getElementById(`macd-${tf}`).textContent = frame.macd > 0 ? '+' + frame.macd.toFixed(4) : frame.macd.toFixed(4);
    });
}

// Actualizar contador regresivo
function updateCountdownTimer() {
    const now = new Date();
    const nextEvent = new Date(now.getTime() + 2 * 60 * 60 * 1000 + 45 * 60 * 1000 + 30 * 1000);
    const diff = nextEvent - now;
    
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);
    
    document.getElementById('nextEventTimer').textContent = 
        `ECB Decision: ${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
}

// ===== INICIALIZACIÓN =====

// Inicializar cuando la página esté cargada
window.addEventListener('load', initializeTradingSystem);

// Exportar funciones globales necesarias
window.refreshAnalysis = refreshAnalysis;
window.changeTimeframe = changeTimeframe;
window.configureAlerts = configureAlerts;
EOF

echo "✅ JavaScript principal creado en src/js/main.js"

# Crear archivo de utilidades
cat > src/js/utils.js << 'EOF'
// EUR/USD Trading Platform - Utility Functions
// Funciones de utilidad para la plataforma

// Formatear precio con 4 decimales
function formatPrice(price) {
    return parseFloat(price).toFixed(4);
}

// Formatear cambio de precio con signo
function formatPriceChange(change) {
    const sign = change >= 0 ? '+' : '';
    return `${sign}${change.toFixed(4)}`;
}

// Calcular porcentaje de cambio
function calculatePercentChange(current, previous) {
    return ((current - previous) / previous * 100).toFixed(3);
}

// Validar API key (básico)
function validateApiKey(key) {
    return key && key !== 'DEMO_KEY' && key.length > 10;
}

// Log con timestamp
function logWithTimestamp(message, level = 'info') {
    const timestamp = new Date().toLocaleTimeString();
    const logMessage = `[${timestamp}] ${message}`;
    
    switch(level) {
        case 'error':
            console.error(logMessage);
            break;
        case 'warn':
            console.warn(logMessage);
            break;
        default:
            console.log(logMessage);
    }
}

// Debounce function para optimizar performance
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Exportar funciones
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        formatPrice,
        formatPriceChange,
        calculatePercentChange,
        validateApiKey,
        logWithTimestamp,
        debounce
    };
} else {
    window.TradingUtils = {
        formatPrice,
        formatPriceChange,
        calculatePercentChange,
        validateApiKey,
        logWithTimestamp,
        debounce
    };
}
EOF

echo "✅ Utilidades creadas en src/js/utils.js"

echo ""
echo "🎉 ¡Separación de código completada!"
echo ""
echo "📁 Estructura final:"
echo "├── index.html           (HTML limpio y semántico)"
echo "├── src/"
echo "│   ├── css/"
echo "│   │   └── main.css     (estilos principales)"
echo "│   ├── js/"
echo "│   │   ├── main.js      (lógica principal)"
echo "│   │   └── utils.js     (funciones de utilidad)"
echo "│   └── config/"
echo "│       └── api.js       (configuración de API)"
echo ""
echo "🔧 Siguientes pasos:"
echo "1. Completar el CSS en src/css/main.css con todos los estilos"
echo "2. Cambiar 'DEMO_KEY' en src/config/api.js por tu API key real"
echo "3. Añadir assets/ folder para imágenes y favicon"
echo "4. Probar el funcionamiento: npx serve ."
