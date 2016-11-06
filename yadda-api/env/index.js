var fs = require('fs')
var _debug = require('debug')
var config = require('./_base')

const debug = _debug('app:env')
debug('Create Environment')
debug(`Apply environment overrides for NODE_ENV "${config.env}".`)

const overridesFilename = `_${config.env}`
let hasOverridesFile
try {
  fs.lstatSync(`${__dirname}/${overridesFilename}.js`)
  hasOverridesFile = true
} catch (e) {}

let overrides
if (hasOverridesFile) {
  overrides = require(`./${overridesFilename}`).default(config)
} else {
  debug(`No configuration overrides found for NODE_ENV "${config.env}"`)
}

module.exports = Object.assign({}, config, overrides)
