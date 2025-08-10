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
