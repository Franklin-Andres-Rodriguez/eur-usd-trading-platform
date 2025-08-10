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
