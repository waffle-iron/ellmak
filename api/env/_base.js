var _debug = require('debug')
var path = require('path')
var argv = require('yargs')('argv')

const debug = _debug('app:env:_base')

const config = {
  env : process.env.NODE_ENV || 'development',
  path_base  : path.resolve(__dirname, '..'),
  dir_client : 'src',
  dir_dist   : 'dist'
}

config.globals = {
  'process.env'  : {
    'NODE_ENV' : JSON.stringify(config.env)
  },
  'NODE_ENV'     : config.env,
  '__DEV__'      : config.env == 'development',
  '__PROD__'     : config.env == 'production',
  '__TEST__'     : config.env == 'test',
  '__DEBUG__'    : config.env === 'development' && !argv.no_debug,
  '__BASENAME__' : JSON.stringify(process.env.BASENAME || '')
}

config.utils_paths = (() => {
  const resolve = path.resolve

  const base = (...args) =>
    resolve.apply(resolve, [config.path_base, ...args])

  return {
    base   : base,
    client : base.bind(null, config.dir_client),
    dist   : base.bind(null, config.dir_dist)
  }
})()

module.exports = config
