var _debug = require('debug')
var argv = require('yargs')('argv')

const debug = _debug('app:env:_base')

const config = {
  env : process.env.NODE_ENV || 'development',
}

config.globals = {
  'process.env'  : {
    'NODE_ENV' : JSON.stringify(config.env)
  },
  'NODE_ENV'     : config.env,
  '__DEV__'      : config.env == 'development',
  '__INT__'      : config.env == 'integration',
  '__STG__'      : config.env == 'staging',
  '__PROD__'     : config.env == 'production',
  '__DEBUG__'    : config.env === 'development' && !argv.no_debug,
  '__BASENAME__' : JSON.stringify(process.env.BASENAME || '')
}

module.exports = config
