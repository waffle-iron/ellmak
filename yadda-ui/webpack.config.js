var webpack = require('webpack')
var cssnano = require('cssnano')
var path = require('path')
var _debug = require('debug')
var env = require('./env')
var CopyWebpackPlugin = require('copy-webpack-plugin')

const debug = _debug('app:webpack:config')
const {__DEV__, __INT__, __STG__, __PROD__} = env.globals

debug('Webpack Configuration')

const config = {
  output: {
    path: "./dist",
    filename: 'index.js'
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm']
  },

  module: {
    loaders: [
      {test: /\.css$/, loaders: ['style', 'css?sourceMap&-minimize' ]},
      {test: /\.scss$/, loaders: ['style', 'css?sourceMap&-minimize', 'sass?sourceMap']},
      {test: /\.html$/, exclude: /node_modules/, loader: 'file?name=[name].[ext]' },
      {test: /\.(png|jpg|svg|woff|woff2)?(\?v=\d+.\d+.\d+)?$/, loader: 'url-loader?limit=8192'},
      {test: /\.(eot|ttf)$/, loader: 'file-loader'},
      {test: /\.elm$/, exclude: [/elm-stuff/, /node_modules/], loader: 'elm-webpack'},
      {test: /bootstrap-sass[\/\\]assets[\/\\]javascripts[\/\\]/, loader: 'imports?jQuery=jquery' },
    ],

    noParse: /\.elm$/
  },

  devServer: {
    historyApiFallback: true,
    hot: true,
    inline: true,
    progress: true,

    // Display only errors to reduce the amount of output.
    stats: 'errors-only',
  },

  sassLoader: {
    includePaths: [path.resolve(__dirname, "./src/styles")]
  }
};

config.plugins = [new CopyWebpackPlugin([{from: 'static'}])]

if (__DEV__) {
  debug('Enable plugins for live development (HotModuleReplacementPlugin, Define, NoErrors).')
  config.plugins.push(
    new webpack.HotModuleReplacementPlugin(),
    new webpack.DefinePlugin({
      __DEV__: __DEV__,
      __INT__: __INT__,
      __STG__: __STG__,
      __PROD__: __PROD__,
      BASE_URL: JSON.stringify("http://localhost:3000/api/v1"),
      UI_VERSION: JSON.stringify("v" + require("./package.json").version),
      API_VERSION: JSON.stringify("v" + require("../yadda-api/package.json").version)
    }),
    new webpack.NoErrorsPlugin()
  )

  config.entry = [ 'bootstrap-loader', './src/index.js', 'webpack/hot/dev-server' ]
}
if (__INT__ || __STG__ || __PROD__) {
  debug('Enable plugins for production (Define, OccurenceOrder, Dedupe, & UglifyJS).')
  config.plugins.push(
    new webpack.DefinePlugin({
      __DEV__: __DEV__,
      __INT__: __INT__,
      __STG__: __STG__,
      __PROD__: __PROD__,
      BASE_URL: JSON.stringify("api/v1"),
      UI_VERSION: JSON.stringify("v" + require("./package.json").version),
      API_VERSION: JSON.stringify("v" + require("../yadda-api/package.json").version)
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

  config.entry = [ 'bootstrap-loader', './src/index.js' ]
}

module.exports = config
