const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

/**
 * EUR/USD Trading Platform - Simplified Webpack Configuration
 *
 * Architecture Decision: Start simple, scale gradually
 * Approach: Remove core-js dependency, focus on ES6+ native support
 * Philosophy: Working foundation first, optimization second
 */
module.exports = (env = {}, argv = {}) => {
  const isProduction = argv.mode === 'production';
  const isDevelopment = !isProduction;

  console.log(`🏗️ Building EUR/USD Trading Platform in ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'} mode`);

  if (isDevelopment) {
    console.log('⚡ Development mode: Hot reload + source maps enabled');
    console.log('🎯 Target: Modern browsers with native ES6+ support');
    console.log('📊 Server will start on http://localhost:8080');
  }

  const config = {
    // Entry point: Single entry for simplicity
    entry: './src/js/main.js',

    // Output: Clean and predictable
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: isProduction ? '[name].[contenthash:8].js' : '[name].js',
      clean: true,
      publicPath: '/'
    },

    // Mode configuration
    mode: isProduction ? 'production' : 'development',

    // Source maps: Fast for development, detailed for production
    devtool: isProduction ? 'source-map' : 'eval-cheap-module-source-map',

    // Module resolution: Clean aliases
    resolve: {
      extensions: ['.js', '.json'],
      alias: {
        '@': path.resolve(__dirname, 'src'),
        '@config': path.resolve(__dirname, 'src/config'),
        '@js': path.resolve(__dirname, 'src/js'),
        '@css': path.resolve(__dirname, 'src/css')
      }
    },

    // Module processing: Simplified without polyfills
    module: {
      rules: [
        // JavaScript: Modern ES6+ without polyfills
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [
                ['@babel/preset-env', {
                  // Target modern browsers - no polyfills needed
                  targets: {
                    browsers: ['Chrome >= 88', 'Firefox >= 85', 'Safari >= 14', 'Edge >= 88']
                  },
                  modules: false,
                  // Remove useBuiltIns to avoid core-js dependency
                  useBuiltIns: false
                }]
              ],
              cacheDirectory: true
            }
          }
        },

        // CSS: Simple loading for development
        {
          test: /\.css$/i,
          use: [
            isProduction
              ? MiniCssExtractPlugin.loader
              : 'style-loader',
            'css-loader'
          ]
        },

        // Assets: Basic asset handling
        {
          test: /\.(png|jpe?g|gif|svg|ico)$/i,
          type: 'asset/resource',
          generator: {
            filename: 'images/[name].[hash:8][ext]'
          }
        }
      ]
    },

    // Plugins: Essential only
    plugins: [
      new HtmlWebpackPlugin({
        template: './index.html',
        filename: 'index.html',
        inject: 'body'
      }),

      // Production CSS extraction
      ...(isProduction ? [
        new MiniCssExtractPlugin({
          filename: '[name].[contenthash:8].css'
        })
      ] : [])
    ],

    // Optimization: Basic for now
    optimization: {
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            chunks: 'all'
          }
        }
      }
    },

    // Development server: Clean and simple
    devServer: {
      static: {
        directory: path.join(__dirname, 'dist')
      },
      host: 'localhost',
      port: 8080,
      hot: true,
      open: true,
      compress: true,
      historyApiFallback: true,

      // Simplified client configuration
      client: {
        logging: 'info',
        overlay: {
          errors: true,
          warnings: false
        }
      }
    },

    // Stats: Clean output
    stats: 'minimal'
  };

  return config;
};
