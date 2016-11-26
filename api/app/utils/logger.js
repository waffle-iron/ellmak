import express from 'express'
import winston from 'winston'
import clc from 'cli-color'

const app = express()

const yTrace = clc.magenta
const yDebug = clc.green
const yInfo = clc.cyan
const yWarn = clc.yellow
const yError = clc.red.bold

var winstonConfig = {
  levels: {
    trace: 4,
    debug: 3,
    info: 2,
    warn: 1,
    error: 0
  },
  colors: {
    trace: 'magenta bold',
    debug: 'green bold',
    info: 'cyan bold',
    warn: 'yellow bold',
    error: 'red bold'
  }
}

winston.addColors(winstonConfig.colors)

var level
if (app.get('env') === 'development') {
  level = 'trace'
} else {
  level = 'info'
}

const logger = new (winston.Logger)({
  levels: winstonConfig.levels,
  exitOnError: false,
  transports: [
    new (winston.transports.Console)({
      level: level,
      colorize: true,
      timestamp: true,
      prettyPrint: true,
      depth: 5,
      handleExceptions: true,
      humanReadableUnhandledException: true
    })
  ]
})

const banner = () => {
  logger.info(yInfo('##    ##    ###    ########  ########     ###          ###    ########  #### '))
  logger.info(yInfo(' ##  ##    ## ##   ##     ## ##     ##   ## ##        ## ##   ##     ##  ##  '))
  logger.info(yInfo('  ####    ##   ##  ##     ## ##     ##  ##   ##      ##   ##  ##     ##  ##  '))
  logger.info(yInfo('   ##    ##     ## ##     ## ##     ## ##     ##    ##     ## ########   ##  '))
  logger.info(yInfo('   ##    ######### ##     ## ##     ## #########    ######### ##         ##  '))
  logger.info(yInfo('   ##    ##     ## ##     ## ##     ## ##     ##    ##     ## ##         ##  '))
  logger.info(yInfo('   ##    ##     ## ########  ########  ##     ##    ##     ## ##        #### '))
  logger.info()
  logger.info(yInfo('4a61736f6e204f7a696173'))
  logger.info()
  logger.info(yInfo('Running %s'), app.get('env'))
  logger.info(yInfo('YADDA_CORS_WHITELIST: %s'), process.env.YADDA_CORS_WHITELIST)
}

const trace = (message, ...rest) => {
  logger.trace(yTrace(message), ...rest)
}

const debug = (message, ...rest) => {
  logger.debug(yDebug(message), ...rest)
}

const info = (message, ...rest) => {
  logger.info(yInfo(message), ...rest)
}

const warn = (message, ...rest) => {
  logger.warn(yWarn(message), ...rest)
}

const error = (message, ...rest) => {
  logger.error(yError(message), ...rest)
}

export { banner, debug, error, info, trace, warn }
