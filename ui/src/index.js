'use strict';

require('../styles/core.scss');
require('./index.html');
var alertify = require('alertify.js');

window.onerror = function(msg, url, line, col, error) {
   // Note that col & error are new to the HTML 5 spec and may not be
   // supported in every browser.  It worked for me in Chrome.
   var extra = !col ? '' : '\ncolumn: ' + col;
   extra += !error ? '' : '\nerror: ' + error;

   // You can view the information in an alert to see things working like this:
   alert("Error: " + msg + "\nurl: " + url + "\nline: " + line + extra);

   // TODO: Report this error via ajax so you can keep track
   //       of what pages have JS issues

   var suppressErrorAlert = true;
   // If you return true, then error alerts (like in older versions of
   // Internet Explorer) will be suppressed.
   return suppressErrorAlert;
};

if (__DEV__) {
  console.info('[UI]', 'Running dev environment')
}

if (__PROD__) {
  console.warn('[UI]', 'Running production environment')
}

var Elm = require('./Main');

var storedFlags = localStorage.getItem('ellmak-flags');
var flags = storedFlags ? JSON.parse(storedFlags) : null;

if (flags === null) {
  flags = {};
  // Set the enviroment flag
  if (__DEV__) {
    flags.env = "development"
  } else if (__INT__) {
    flags.env = "integration"
  } else if (__STG__) {
    flags.env = "staging"
  } else if (__PROD__) {
    flags.env = "production"
  }

  // Set the base API URL (the value is replaced by the webpack DefinePlugin)
  flags.baseUrl = BASE_URL;
  flags.wsBaseUrl = WS_BASE_URL;

  // Set the version information (the value is replaced by the webpack DefinePlugin)
  flags.apiVersion = API_VERSION;
  flags.uiVersion = UI_VERSION;

  // Set the auth related state
  flags.username = ""
  flags.token = ""
  flags.expiry = 0

  // Set the home route
  flags.route = ""
}

flags.randomSeed = Math.floor(Math.random()*0xFFFFFFFF);

var elmApp = Elm.Main.fullscreen(flags);

elmApp.ports.storeFlags.subscribe(function(flags) {
  localStorage.setItem('ellmak-flags', JSON.stringify(flags));
});

elmApp.ports.removeFlags.subscribe(function() {
  localStorage.removeItem('ellmak-flags');
});

elmApp.ports.alertify.subscribe(function(config) {
  alertify.logPosition(config.position);
  alertify.maxLogItems(config.maxItems);
  alertify.delay(config.closeDelay);
  alertify.closeLogOnClick(config.cloc);

  var lt = config.logType
  if (lt === 'success') {
    alertify.success(config.message);
  } else if (lt === 'error') {
    alertify.error(config.message);
  } else {
    alertify.log(config.message);
  }
});
