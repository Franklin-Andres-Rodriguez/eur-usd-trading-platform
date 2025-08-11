# 🤝 Contributing to EUR/USD Trading Platform

Welcome to our development community! This guide embodies **software craftsmanship principles** and **professional development practices** to ensure our trading platform maintains the highest standards of code quality, security, and maintainability.

## 🎯 **Our Development Philosophy**

**We build software like financial professionals manage risk - with rigor, transparency, and continuous improvement.**

### **Core Values**
- **🔍 Quality First:** Every line of code affects real financial decisions
- **🚀 Continuous Learning:** Technology evolves, and so do we
- **🤝 Collaborative Excellence:** Code reviews are learning opportunities
- **📊 Data-Driven Decisions:** Metrics guide our development choices
- **🔒 Security Mindset:** Financial platforms demand paranoid security practices

---

## 📋 **Quick Start for Contributors**

### **🚀 First Contribution (30 minutes)**
```bash
# 1. Fork and clone the repository
git clone https://github.com/yourusername/eur-usd-trading.git
cd eur-usd-trading

# 2. Install dependencies and verify setup
npm install
npm test        # All tests should pass
npm run lint    # Code should be clean

# 3. Create feature branch following naming convention
git checkout -b feature/add-moving-average-indicator

# 4. Make your changes, following our standards
# 5. Run quality checks before committing
npm run test:coverage    # Ensure >80% coverage
npm run lint:fix        # Auto-fix formatting issues
npm run build          # Verify production build

# 6. Commit with conventional commit format
git commit -m "feat(indicators): add simple moving average calculation

- Implement SMA calculation in utils/calculations/
- Add comprehensive unit tests with edge cases
- Include TypeScript definitions for future migration
- Performance optimized for real-time updates

Closes #123"

# 7. Push and create pull request
git push origin feature/add-moving-average-indicator
```

### **🎓 Learning Path for New Contributors**
1. **Week 1:** Read README.md + ARCHITECTURE.md, fix one small bug
2. **Week 2:** Add one new utility function with comprehensive tests
3. **Week 3:** Contribute one new UI component following our patterns
4. **Week 4:** Lead code review for another contributor's PR

---

## 🛠️ **Development Workflow**

### **Branch Strategy (GitHub Flow + Quality Gates)**
```
main (production-ready)
├── develop (integration branch)
├── feature/descriptive-name
├── bugfix/issue-number-description
├── hotfix/critical-security-fix
└── refactor/performance-optimization
```

### **Branch Naming Conventions**
```bash
# ✅ Good Examples
feature/add-rsi-indicator
bugfix/price-display-rounding-error
hotfix/api-key-security-leak
refactor/chart-performance-optimization
docs/api-integration-guide

# ❌ Avoid
my-changes
fix-stuff
update
new-feature
```

### **Commit Message Standards (Conventional Commits)**

**Format:** `type(scope): description`

**Types:**
- `feat`: New feature for users
- `fix`: Bug fix for users  
- `docs`: Documentation changes
- `style`: Code formatting (no logic changes)
- `refactor`: Code restructuring (no behavior change)
- `test`: Adding or updating tests
- `perf`: Performance improvements
- `chore`: Build process, dependencies, tooling

**Examples:**
```bash
# ✅ Excellent Examples
feat(charts): add Bollinger Bands technical indicator

fix(api): handle Alpha Vantage rate limit gracefully  

docs(readme): update installation instructions for Node 18+

refactor(utils): optimize price calculation performance by 40%

test(indicators): add edge case coverage for zero-value handling

perf(charts): implement canvas virtualization for 10k+ data points
```

---

## 🧪 **Testing Standards (TDD Approach)**

### **Testing Philosophy: Red-Green-Refactor**
Following **Kent Beck's TDD principles** and **Kent C. Dodds' testing practices**:

1. **🔴 Red:** Write failing test first
2. **🟢 Green:** Write minimal code to pass
3. **🔵 Refactor:** Improve code while keeping tests green

### **Test Coverage Requirements**
```javascript
// ✅ Required Coverage Thresholds
const coverageThresholds = {
  global: {
    branches: 80,
    functions: 85,
    lines: 85,
    statements: 85
  },
  // Critical financial calculations require 100% coverage
  './src/utils/calculations/': {
    branches: 100,
    functions: 100,
    lines: 100,
    statements: 100
  }
};
```

### **Testing Patterns We Follow**

**Unit Tests (Jest):**
```javascript
// ✅ Example: Testing financial calculations
describe('calculateMovingAverage', () => {
  test('should calculate SMA correctly for valid price data', () => {
    // Arrange
    const prices = [1.0800, 1.0820, 1.0840, 1.0860, 1.0880];
    const period = 5;
    
    // Act
    const result = calculateMovingAverage(prices, period);
    
    // Assert
    expect(result).toBeCloseTo(1.0840, 4); // 4 decimal precision for forex
  });
  
  test('should handle edge cases gracefully', () => {
    expect(() => calculateMovingAverage([], 5)).not.toThrow();
    expect(calculateMovingAverage([1.0800], 5)).toBeNull();
  });
});
```

**Integration Tests (Cypress):**
```javascript
// ✅ Example: Testing user workflows
describe('Price Alert Workflow', () => {
  it('should create and trigger price alert successfully', () => {
    cy.visit('/');
    cy.get('[data-testid=price-alert-button]').click();
    cy.get('[data-testid=target-price]').type('1.0900');
    cy.get('[data-testid=create-alert]').click();
    
    // Mock price update to trigger alert
    cy.intercept('GET', '/api/prices', { eurUsd: 1.0901 });
    cy.wait(1000);
    
    cy.get('[data-testid=alert-notification]').should('be.visible');
  });
});
```

---

## 🎨 **Code Style Standards**

### **JavaScript/ES6+ Guidelines**

**Follows Airbnb Style Guide + Financial Industry Adaptations:**

```javascript
// ✅ Excellent Code Example
/**
 * Calculates Relative Strength Index (RSI) for forex pair
 * @param {number[]} prices - Array of closing prices (minimum 15 values)
 * @param {number} period - RSI period (typically 14)
 * @returns {number|null} RSI value (0-100) or null if insufficient data
 */
const calculateRSI = (prices, period = 14) => {
  // Input validation - critical for financial calculations
  if (!Array.isArray(prices) || prices.length < period + 1) {
    return null;
  }
  
  const priceChanges = prices.slice(1).map((price, index) => 
    price - prices[index]
  );
  
  const gains = priceChanges.map(change => Math.max(change, 0));
  const losses = priceChanges.map(change => Math.abs(Math.min(change, 0)));
  
  const avgGain = gains.slice(-period).reduce((sum, gain) => sum + gain, 0) / period;
  const avgLoss = losses.slice(-period).reduce((sum, loss) => sum + loss, 0) / period;
  
  if (avgLoss === 0) return 100; // Prevent division by zero
  
  const relativeStrength = avgGain / avgLoss;
  const rsi = 100 - (100 / (1 + relativeStrength));
  
  // Return with forex precision
  return Math.round(rsi * 100) / 100;
};
```

**Key Principles:**
- **Clear naming:** Functions and variables explain their purpose
- **Input validation:** Always validate financial data inputs
- **Error handling:** Graceful handling of edge cases
- **Documentation:** JSDoc for all public functions
- **Precision:** Proper rounding for financial calculations

### **Component Organization Pattern**

```javascript
// ✅ React Component Example (future migration ready)
const PriceChart = ({
  priceData,
  indicators = [],
  timeframe = '1h',
  onTimeframeChange,
  className = ''
}) => {
  // State management
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // Effects
  useEffect(() => {
    loadPriceData(timeframe);
  }, [timeframe]);
  
  // Event handlers
  const handleTimeframeChange = useCallback((newTimeframe) => {
    setIsLoading(true);
    onTimeframeChange?.(newTimeframe);
  }, [onTimeframeChange]);
  
  // Early returns for edge cases
  if (error) return <ErrorDisplay error={error} />;
  if (isLoading) return <LoadingSpinner />;
  if (!priceData?.length) return <EmptyState />;
  
  // Main render
  return (
    <div className={`price-chart ${className}`}>
      {/* Component JSX */}
    </div>
  );
};
```

### **CSS/Styling Standards (BEM + Financial UI)**

```css
/* ✅ Professional Trading Platform Styling */
.price-chart {
  /* Component block */
  position: relative;
  background: var(--chart-background);
  border: 1px solid var(--chart-border);
  border-radius: 8px;
  font-family: 'Monaco', 'Menlo', monospace; /* Monospace for price precision */
}

.price-chart__canvas {
  /* Canvas element */
  width: 100%;
  height: 400px;
  cursor: crosshair;
}

.price-chart__price-label {
  /* Price display element */
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--price-text);
  letter-spacing: 0.5px; /* Improved readability for numbers */
}

.price-chart__price-label--positive {
  /* Price increase modifier */
  color: var(--color-green);
}

.price-chart__price-label--negative {
  /* Price decrease modifier */
  color: var(--color-red);
}

/* Financial industry color standards */
:root {
  --color-green: #00c851;  /* Bullish/positive */
  --color-red: #ff4444;    /* Bearish/negative */
  --color-neutral: #666;   /* Unchanged */
  --chart-background: #1a1a1a;
  --chart-grid: #333;
}
```

---

## 📝 **Code Review Process**

### **Review Checklist (Based on Clean Code Principles)**

**🔍 Technical Review:**
- [ ] Code follows established patterns and conventions
- [ ] All functions have single responsibility
- [ ] Input validation for financial calculations
- [ ] Error handling doesn't expose sensitive information
- [ ] Performance impact assessed for real-time features
- [ ] Security implications considered and addressed

**🧪 Quality Assurance:**
- [ ] New tests cover happy path and edge cases
- [ ] Test coverage meets or exceeds threshold requirements
- [ ] All existing tests pass without modification
- [ ] Code can be understood without extensive comments
- [ ] Documentation updated for public API changes

**💼 Business Logic:**
- [ ] Financial calculations are mathematically correct
- [ ] Feature aligns with trading platform requirements
- [ ] UX improvements enhance trading workflow
- [ ] Performance maintains real-time responsiveness

### **Review Comments Guidelines**

**🎯 Constructive Feedback Examples:**
```markdown
# ✅ Excellent Review Comments

**Suggestion:** Consider extracting this calculation into a utility function
```javascript
// Current approach:
const rsi = 100 - (100 / (1 + avgGain / avgLoss));

// Suggested refactor:
const rsi = calculateRSIFromAverages(avgGain, avgLoss);
```
This would improve testability and reusability across indicators.

**Security Concern:** API key is visible in browser console
Please move this to environment variables or secure configuration.

**Performance Optimization:** This loop could be expensive with large datasets
Consider implementing virtualization or pagination for >1000 data points.

**Testing Gap:** Missing edge case for zero prices
Add test case for `calculateMovingAverage([0, 0, 0], 3)` scenario.
```

### **Approval Criteria**
- ✅ **2 approvals** from team members required
- ✅ **All CI checks passing** (tests, linting, security scan)
- ✅ **Architectural review** for substantial changes
- ✅ **Security review** for API or data handling changes

---

## 🔒 **Security Guidelines**

### **Financial Platform Security Checklist**

**API Security:**
- [ ] API keys stored in environment variables only
- [ ] Rate limiting implemented for all external calls
- [ ] Input sanitization for all user data
- [ ] HTTPS enforcement for all communications
- [ ] No sensitive data in console.log statements

**Data Protection:**
- [ ] No personal financial information stored locally
- [ ] Price data validated before display
- [ ] Error messages don't reveal system internals
- [ ] Cross-site scripting (XSS) prevention
- [ ] Content Security Policy (CSP) headers implemented

**Code Security:**
```javascript
// ✅ Secure API call pattern
const fetchPriceData = async (pair) => {
  try {
    // Input validation
    if (!isValidCurrencyPair(pair)) {
      throw new Error('Invalid currency pair');
    }
    
    // Secure API call with timeout
    const response = await fetch(`${API_BASE_URL}/prices`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${process.env.API_KEY}`, // Server-side only
        'Content-Type': 'application/json',
      },
      timeout: 5000, // Prevent hanging requests
    });
    
    if (!response.ok) {
      throw new Error(`API Error: ${response.status}`);
    }
    
    // Validate response data
    const data = await response.json();
    return validatePriceData(data);
    
  } catch (error) {
    // Safe error logging (no sensitive data)
    console.error('Price fetch failed:', error.message);
    throw new Error('Unable to fetch price data');
  }
};
```

---

## 📊 **Performance Standards**

### **Performance Budgets**
```javascript
// Performance thresholds we maintain
const performanceBudgets = {
  // Lighthouse scores (minimum acceptable)
  performance: 90,
  accessibility: 95,
  bestPractices: 95,
  seo: 90,
  
  // Bundle size limits
  mainBundle: '500KB',    // Gzipped
  vendorBundle: '1MB',    // Gzipped
  cssBundle: '50KB',      // Gzipped
  
  // Runtime performance
  firstContentfulPaint: '1.5s',
  largestContentfulPaint: '2.0s',
  timeToInteractive: '3.0s',
  
  // Trading-specific metrics
  priceUpdateLatency: '100ms',   // Real-time price updates
  chartRenderTime: '500ms',      // Chart refresh time
  apiResponseTime: '300ms',      // Average API response
};
```

### **Performance Testing**
```javascript
// ✅ Performance test example
describe('Chart Performance', () => {
  test('should render 1000 price points within budget', async () => {
    const startTime = performance.now();
    
    await renderChart(generateMockPrices(1000));
    
    const renderTime = performance.now() - startTime;
    expect(renderTime).toBeLessThan(500); // 500ms budget
  });
});
```

---

## 🚀 **Deployment & Release Process**

### **Release Workflow**
1. **Feature Complete:** All acceptance criteria met
2. **Code Review:** Minimum 2 approvals + technical lead review
3. **Testing:** All tests pass + manual QA verification
4. **Security Scan:** No critical vulnerabilities
5. **Performance Validation:** Meets performance budgets
6. **Staging Deployment:** Full integration testing
7. **Production Release:** Blue-green deployment with rollback plan

### **Version Numbering (Semantic Versioning)**
```
MAJOR.MINOR.PATCH

1.0.0 → 1.0.1  (Bug fix - patch)
1.0.1 → 1.1.0  (New feature - minor)
1.1.0 → 2.0.0  (Breaking change - major)
```

### **Release Notes Template**
```markdown
# Release v1.2.0 - Real-Time Price Alerts

## 🚀 New Features
- **Price Alerts:** Set custom price targets with browser notifications
- **Technical Indicators:** Added RSI and MACD indicators
- **Dark Theme:** Professional dark mode for extended trading sessions

## 🐛 Bug Fixes
- Fixed price display rounding errors for JPY pairs
- Resolved chart flickering on mobile devices
- Improved API error handling for network timeouts

## ⚡ Performance Improvements
- Chart rendering optimized by 40% for large datasets
- Reduced bundle size by 15% through code splitting
- API response caching reduces redundant calls by 60%

## 🔒 Security Updates
- Updated all dependencies to latest secure versions
- Enhanced API key protection mechanisms
- Improved input validation for user data

## 📋 Migration Notes
No breaking changes - automatic update recommended.
```

---

## 🎓 **Learning Resources**

### **Recommended Reading for Contributors**
- **Clean Code** by Robert C. Martin - Code quality fundamentals
- **Refactoring** by Martin Fowler - Code improvement techniques
- **Design Patterns** by Gang of Four - Reusable solutions
- **You Don't Know JS** by Kyle Simpson - JavaScript mastery
- **Designing Data-Intensive Applications** by Martin Kleppmann - System design

### **Internal Resources**
- **Architecture Documentation:** `docs/ARCHITECTURE.md`
- **API Reference:** `docs/API_REFERENCE.md`
- **Testing Guide:** `docs/TESTING.md`
- **Security Handbook:** `docs/SECURITY.md`

### **External Tools & Resources**
- **Alpha Vantage API Docs:** https://www.alphavantage.co/documentation/
- **Chart.js Documentation:** https://www.chartjs.org/docs/
- **MDN Web Docs:** https://developer.mozilla.org/
- **Can I Use:** https://caniuse.com/

---

## 🤝 **Community & Support**

### **Getting Help**
1. **Search existing issues** for similar problems
2. **Check documentation** in `docs/` folder
3. **Ask in Discussions** for general questions
4. **Create issue** for bugs or feature requests
5. **Join code review** to learn from others

### **Recognition System**
We celebrate contributions through:
- **🏆 Contributor of the Month** - Outstanding code quality and mentorship
- **🎯 Bug Hunter** - Finding and fixing critical issues
- **📚 Documentation Hero** - Improving project documentation
- **🔧 Performance Optimizer** - Measurable performance improvements
- **🛡️ Security Guardian** - Identifying and fixing security issues

### **Mentorship Opportunities**
- **Pair Programming Sessions** - Learn complex features hands-on
- **Code Review Mentoring** - Improve review skills with guidance
- **Architecture Discussions** - Participate in technical decisions
- **Conference Talks** - Present our work at developer conferences

---

## 📞 **Contact & Communication**

### **Communication Channels**
- **GitHub Issues:** Bug reports and feature requests
- **GitHub Discussions:** General questions and ideas
- **Code Reviews:** Technical discussions and learning
- **Email:** security@yourplatform.com (security issues only)

### **Response Time Expectations**
- **Critical Security Issues:** <2 hours
- **Bug Reports:** <24 hours
- **Feature Requests:** <48 hours
- **Code Reviews:** <24 hours (weekdays)
- **General Questions:** <72 hours

---

## 📄 **Legal & Compliance**

### **Contributor License Agreement**
By contributing, you agree that:
- Your contributions are your original work
- You grant us license to use your contributions
- Your contributions don't violate any third-party rights
- You understand this is an educational trading platform

### **Code of Conduct**
We foster an inclusive, professional environment:
- **Be respectful** in all interactions
- **Focus on technical merit** in discussions
- **Help others learn** through constructive feedback
- **Report issues** if community standards are violated

---

**Thank you for contributing to the EUR/USD Trading Platform! Together, we're building professional-grade financial software that demonstrates the highest standards of software engineering excellence.**

*Remember: In financial software, bugs aren't just inconveniences - they can impact real trading decisions. Let's build something we're proud to put our names on.*
