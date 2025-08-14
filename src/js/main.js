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

// Fucntion for toggling dark mode
document.addEventListener('DOMContentLoaded', () => {
    const toggleSwitch = document.getElementById('theme-toggle');
    const body = document.body;
    const icon = document.querySelector('.switch .icon');

    // Load saved theme
    if (localStorage.getItem('theme') === 'dark') {
        body.classList.add('dark-mode');
        toggleSwitch.checked = true;
        if (icon) icon.textContent = '🌙';
    } else {
        if (icon) icon.textContent = '☀️';
    }

    toggleSwitch.addEventListener('change', () => {
        if (toggleSwitch.checked) {
            body.classList.add('dark-mode');
            localStorage.setItem('theme', 'dark');
            if (icon) icon.textContent = '🌙';
        } else {
            body.classList.remove('dark-mode');
            localStorage.setItem('theme', 'light');
            if (icon) icon.textContent = '☀️';
        }
    });
});


// ===== INICIALIZACIÓN =====

// Inicializar cuando la página esté cargada
window.addEventListener('load', initializeTradingSystem);

// Exportar funciones globales necesarias
window.refreshAnalysis = refreshAnalysis;
window.changeTimeframe = changeTimeframe;
window.configureAlerts = configureAlerts;
