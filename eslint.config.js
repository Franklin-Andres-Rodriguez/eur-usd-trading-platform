import js from '@eslint/js';

export default [
  js.configs.recommended,
  
  {
    files: ['**/*.js'],
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: 'module',
      globals: {
        Chart: 'readonly',
        API_CONFIG: 'readonly',
        tradingSystem: 'writable',
        console: 'readonly',
        document: 'readonly',
        window: 'readonly',
        localStorage: 'readonly'
      }
    },
    
    rules: {
      'no-unused-vars': 'warn',
      'no-console': 'off',
      'prefer-const': 'error',
      'no-var': 'error',
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-script-url': 'error',
      'eqeqeq': 'error',
      'no-magic-numbers': ['warn', { 
        ignore: [0, 1, -1, 100],
        ignoreArrayIndexes: true 
      }]
    }
  },
  
  {
    files: ['webpack.config.js'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: {
        __dirname: 'readonly',
        require: 'readonly',
        module: 'readonly'
      }
    }
  },
  
  {
    files: ['docs/**/*.js', 'scripts/**/*.js'],
    rules: {
      'no-console': 'off'
    }
  }
];
