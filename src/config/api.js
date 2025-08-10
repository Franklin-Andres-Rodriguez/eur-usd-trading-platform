const API_CONFIG = {
    alphaVantage: {
        apiKey: '741EE1LJP869A2YP',
        baseUrl: 'https://www.alphavantage.co/query',
        active: true,
        requestsToday: 0,
        limit: 500,
        quality: 'premium',
        lastRequest: null
    },
    cors_proxy: 'https://api.allorigins.win/raw?url=',
    fallback: {
        active: true,
        quality: 'realistic'
    }
};

console.log('🔑 API Config loaded - Alpha Vantage key configured');

if (typeof module !== 'undefined' && module.exports) {
    module.exports = API_CONFIG;
} else {
    window.API_CONFIG = API_CONFIG;
}
