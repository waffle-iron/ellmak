var webpack = require('webpack')
var _debug = require('debug')
var path = require('path')
var nodeExternals = require('webpack-node-externals');
var env = require('../env')

const debug = _debug('app:webpack:config')
const paths = env.utils_paths
const {__DEV__, __PROD__, __TEST__} = env.globals

debug('Webpack Configuration')

config = {
  entry: './app/bin/www.js',
  target: 'node',
  resolve: {
    root: paths.base(env.dir_client)
  },
  externals: [nodeExternals()],
  devtool: 'sourcemap',
  output: {
    path: paths.base(env.dir_dist),
    filename: 'yadda-api.js'
  },
  module: {
    preLoaders: [
      {
        test: /\.(js|jsx)$/,
        loader: 'eslint',
        exclude: /node_modules/
      }
    ],
    loaders: [{
      test: /\.(js|jsx)$/,
      exclude: /node_modules/,
      loader: 'babel',
      query: {
        cacheDirectory: true,
        plugins: ['transform-object-rest-spread'],
        presets: ['es2015'],
        env: {
          development: {
            retainLines: true
          }
        }
      }
    }],
  },
  eslint: {
    configFile: path.join(__dirname, '.eslintrc'),
    emitWarning: __DEV__
  },
  plugins: [
    new webpack.BannerPlugin('require("source-map-support").install();', { raw: true, entryOnly: false })
  ]
}

module.exports = config
