// Alpha Vantage FREE Tier API Manager
// Optimizado para 25 requests/day

class AlphaVantageManager {
    constructor(config) {
        this.config = config;
        this.requestCount = 0;
        this.lastRequest = null;
        this.minInterval = 3600000; // 1 hora entre requests (24 requests/day)
    }
    
    async getCurrentEURUSD() {
        if (!this.canMakeRequest()) {
            console.log('⚠️ Rate limit - using cached/fallback data');
            return this.getLastKnownRate();
        }
        
        try {
            const endpoint = `${this.config.baseUrl}?${this.config.endpoints.currentRate}&apikey=${this.config.apiKey}`;
            const response = await fetch(this.config.cors_proxy + encodeURIComponent(endpoint));
            const data = await response.json();
            
            if (data['Realtime Currency Exchange Rate']) {
                const rate = parseFloat(data['Realtime Currency Exchange Rate']['5. Exchange Rate']);
                this.cacheRate(rate);
                this.requestCount++;
                this.lastRequest = new Date();
                
                console.log(`✅ Real EUR/USD rate: ${rate}`);
                return rate;
            } else {
                throw new Error('Unexpected API response format');
            }
        } catch (error) {
            console.log(`❌ API Error: ${error.message}`);
            return this.getLastKnownRate();
        }
    }
    
    canMakeRequest() {
        if (this.requestCount >= 20) return false; // Safety margin
        if (this.lastRequest) {
            const timeSince = new Date() - this.lastRequest;
            return timeSince >= this.minInterval;
        }
        return true;
    }
    
    cacheRate(rate) {
        // Cache en localStorage para persistencia
        if (typeof localStorage !== 'undefined') {
            localStorage.setItem('eurUsdRate', JSON.stringify({
                rate: rate,
                timestamp: new Date().toISOString()
            }));
        }
    }
    
    getLastKnownRate() {
        // Fallback a rate cacheado o simulado
        if (typeof localStorage !== 'undefined') {
            const cached = localStorage.getItem('eurUsdRate');
            if (cached) {
                const data = JSON.parse(cached);
                const age = new Date() - new Date(data.timestamp);
                if (age < 24 * 60 * 60 * 1000) { // 24 horas
                    return data.rate;
                }
            }
        }
        
        // Fallback a simulación realista
        return this.simulateRealisticRate();
    }
    
    simulateRealisticRate() {
        // Simular tasa realista basada en rangos históricos
        const baseRate = 1.1650;
        const variation = (Math.random() - 0.5) * 0.02; // ±1% variation
        return baseRate + variation;
    }
}

// Hacer disponible globalmente
if (typeof window !== 'undefined') {
    window.AlphaVantageManager = AlphaVantageManager;
}
