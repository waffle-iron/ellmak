import _debug from 'debug'

const debug = _debug('app:config:_base')

const config = {
  env : process.env.NODE_ENV || 'development',
}
