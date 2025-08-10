// API Configuration - EUR/USD Trading Platform
// FREE TIER: Alpha Vantage endpoints optimizados

const API_CONFIG = {
    alphaVantage: {
        apiKey: '741EE1LJP869A2YP',
        baseUrl: 'https://www.alphavantage.co/query',
        active: true,
        requestsToday: 0,
        limit: 25, // 25 requests/day en FREE tier (no 500)
        quality: 'standard',
        lastRequest: null,
        
        // Endpoints FREE disponibles
        endpoints: {
            // ✅ GRATUITO - Tasa actual EUR/USD
            currentRate: 'function=CURRENCY_EXCHANGE_RATE&from_currency=EUR&to_currency=USD',
            
            // ✅ GRATUITO - Datos diarios EUR/USD (últimos 100 días)
            dailyData: 'function=FX_DAILY&from_symbol=EUR&to_symbol=USD',
            
            // ✅ GRATUITO - Datos semanales EUR/USD
            weeklyData: 'function=FX_WEEKLY&from_symbol=EUR&to_symbol=USD',
            
            // ❌ PREMIUM - Intraday data (1min, 5min, 15min, 30min, 60min)
            // intradayData: 'function=FX_INTRADAY&from_symbol=EUR&to_symbol=USD&interval=1min'
        }
    },
    cors_proxy: 'https://api.allorigins.win/raw?url=',
    fallback: {
        active: true,
        quality: 'realistic',
        updateInterval: 300000 // 5 minutos para plan gratuito
    }
};

console.log('🔑 API Config loaded - Alpha Vantage FREE tier optimized');

// Export para compatibilidad
if (typeof module !== 'undefined' && module.exports) {
    module.exports = API_CONFIG;
} else {
    window.API_CONFIG = API_CONFIG;
}
