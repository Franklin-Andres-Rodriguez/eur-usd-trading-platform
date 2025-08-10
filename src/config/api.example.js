// API Configuration Template
// Copy this file to api.js and add your actual API keys

const API_CONFIG = {
    alphaVantage: {
        apiKey: 'YOUR_ALPHA_VANTAGE_API_KEY', // Get free key at alphavantage.co
        baseUrl: 'https://www.alphavantage.co/query',
        rateLimit: 500 // requests per day
    },
    fallback: {
        enabled: true,
        simulation: 'realistic' // 'realistic' | 'demo'
    }
};

export default API_CONFIG;
