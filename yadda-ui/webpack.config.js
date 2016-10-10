var webpack = require('webpack')
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
        loader: "style-loader!css-loader"
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
      }
    ],

    noParse: /\.elm$/
  },

  devServer: {
    inline: true,
    stats: 'errors-only'
  }
};

config.plugins = [
  new CopyWebpackPlugin([
    { from: 'static' }
  ])
]

if (__PROD__) {
  debug('Enable plugins for production (OccurenceOrder, Dedupe, & UglifyJS).')
  config.plugins.push(
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
