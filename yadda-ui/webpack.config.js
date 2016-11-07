var webpack = require('webpack')
var cssnano = require('cssnano')
var _debug = require('debug')
var env = require('./env')
var CopyWebpackPlugin = require('copy-webpack-plugin')

const debug = _debug('app:webpack:config')
const {__DEV__, __PROD__, __TEST__} = env.globals

debug('Webpack Configuration')

const config = {
  entry: './src/index.js',

  output: {
    path: './dist',
    filename: 'index.js'
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm']
  },

  module: {
    loaders: [
      {
        test: /\.css$/,
        loaders: [
          'style',
          'css?sourceMap&-minimize',
          'postcss'
        ]
      },
      {
        test: /\.scss$/,
        loaders: [
          'style',
          'css?sourceMap&-minimize',
          'postcss',
          'sass?sourceMap'
        ]
      },
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file?name=[name].[ext]'
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack'
      },
      { test: /\.woff(\?.*)?$/,  loader: 'url?prefix=fonts/&name=[path][name].[ext]&limit=10000&mimetype=application/font-woff' },
      { test: /\.woff2(\?.*)?$/, loader: 'url?prefix=fonts/&name=[path][name].[ext]&limit=10000&mimetype=application/font-woff2' },
      { test: /\.otf(\?.*)?$/,   loader: 'file?prefix=fonts/&name=[path][name].[ext]&limit=10000&mimetype=font/opentype' },
      { test: /\.ttf(\?.*)?$/,   loader: 'url?prefix=fonts/&name=[path][name].[ext]&limit=10000&mimetype=application/octet-stream' },
      { test: /\.eot(\?.*)?$/,   loader: 'file?prefix=fonts/&name=[path][name].[ext]' },
      { test: /\.svg(\?.*)?$/,   loader: 'url?prefix=fonts/&name=[path][name].[ext]&limit=10000&mimetype=image/svg+xml' },
      { test: /\.(png|jpg)$/,    loader: 'url?limit=8192' }
    ],

    noParse: /\.elm$/
  },

  devServer: {
    inline: true,
    stats: 'errors-only'
  },

  sassLoader: {
    includePaths: 'src/styles'
  }
};

config.postcss = [
  cssnano({
    autoprefixer: {
      add: true,
      remove: true,
      browsers: ['last 2 versions']
    },

    discardComments: {
      removeAll: true
    },

    safe: true,

    sourcemap: true
  })
]

config.plugins = [
  new CopyWebpackPlugin([
    { from: 'static' }
  ])
]

if (__DEV__) {
  debug('Enable plugins for live development (Define, NoErrors).')
  config.plugins.push(
    new webpack.DefinePlugin({
      __DEV__: __DEV__,
      __PROD__: __PROD__,
      BASE_URL: JSON.stringify("http://localhost:3000/api/v1"),
      UI_VERSION: JSON.stringify("v" + require("./package.json").version)
    }),
    new webpack.NoErrorsPlugin()
  )
}
if (__PROD__) {
  debug('Enable plugins for production (OccurenceOrder, Dedupe, & UglifyJS).')
  config.plugins.push(
    new webpack.DefinePlugin({
      __DEV__: __DEV__,
      __PROD__: __PROD__,
      BASE_URL: JSON.stringify("api/v1"),
      UI_VERSION: JSON.stringify("v" + require("./package.json").version)
    }),
    new webpack.optimize.OccurrenceOrderPlugin(),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        unused: true,
        dead_code: true,
        warnings: false
      }
    })
  )
}

module.exports = config
