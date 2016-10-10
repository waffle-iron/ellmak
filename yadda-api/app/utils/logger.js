var express = require('express');
var winston = require('winston');
var clc = require('cli-color');

var app = express();

var clc_trace = clc.magenta;
var clc_debug = clc.green;
var clc_info = clc.cyan;
var clc_warn = clc.yellow;
var clc_error = clc.red.bold;

var dataq_config = {
  levels: {
    trace: 4,
    debug: 3,
    info:  2,
    warn:  1,
    error: 0
  },
  colors: {
    trace: 'magenta bold',
    debug: 'green bold',
    info:  'cyan bold',
    warn:  'yellow bold',
    error: 'red bold'
  }
};

winston.addColors(dataq_config.colors);

var level
if (app.get('env') == 'development') {
  level = 'trace';
} else {
  level = 'info';
}

var logger = new (winston.Logger)({
  levels: dataq_config.levels,
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
});

module.exports = {
  banner: function() {
    logger.info(clc_info('##    ##    ###    ########  ########     ###          ###    ########  #### '));
    logger.info(clc_info(' ##  ##    ## ##   ##     ## ##     ##   ## ##        ## ##   ##     ##  ##  '));
    logger.info(clc_info('  ####    ##   ##  ##     ## ##     ##  ##   ##      ##   ##  ##     ##  ##  '));
    logger.info(clc_info('   ##    ##     ## ##     ## ##     ## ##     ##    ##     ## ########   ##  '));
    logger.info(clc_info('   ##    ######### ##     ## ##     ## #########    ######### ##         ##  '));
    logger.info(clc_info('   ##    ##     ## ##     ## ##     ## ##     ##    ##     ## ##         ##  '));
    logger.info(clc_info('   ##    ##     ## ########  ########  ##     ##    ##     ## ##        #### '));
    logger.info();
    logger.info(clc_info('4a61736f6e204f7a696173'));
    logger.info();
    logger.info(clc_info('Running %s'), app.get('env'));
  },
  trace: function() {
    var args = new Array(arguments.length);
    for(var i = 0; i < args.length; ++i) {
        args[i] = arguments[i];
    }
    var message = args.shift();
    var colored = clc_trace(message);
    args.unshift(colored)
    logger.trace.apply(null, args);
  },
  debug: function() {
    var args = new Array(arguments.length);
    for(var i = 0; i < args.length; ++i) {
        args[i] = arguments[i];
    }
    var message = args.shift();
    var colored = clc_debug(message);
    args.unshift(colored)
    logger.debug.apply(null, args);
  },
  info: function() {
    var args = new Array(arguments.length);
    for(var i = 0; i < args.length; ++i) {
        args[i] = arguments[i];
    }
    var message = args.shift();
    var colored = clc_info(message);
    args.unshift(colored)
    logger.info.apply(null, args);
  },
  warn: function() {
    var args = new Array(arguments.length);
    for(var i = 0; i < args.length; ++i) {
        args[i] = arguments[i];
    }
    var message = args.shift();
    var colored = clc_warn(message);
    args.unshift(colored)
    logger.warn.apply(null, args);
  },
  error: function() {
    var args = new Array(arguments.length);
    for(var i = 0; i < args.length; ++i) {
        args[i] = arguments[i];
    }
    var message = args.shift();
    var colored = clc_error(message);
    args.unshift(colored)
    logger.error.apply(null, args);
  }
};
