'use strict';

require('./styles/core.scss');
require('./index.html');

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
  console.info('[YADDA-UI]', 'Running dev environment')
}

if (__PROD__) {
  console.warn('[YADDA-UI]', 'Running production environment')
}

var Elm = require('./Main');

var storedState = localStorage.getItem('yadda-model');
var initialState = storedState ? JSON.parse(storedState) : null;

if (initialState === null) {
  initialState = {};
  initialState.dev = __DEV__;
  initialState.prod = __PROD__;
  initialState.baseUrl = BASE_URL;
  initialState.apiVersion = "";
  initialState.uiVersion = UI_VERSION;
  initialState.authModel = {
    username: "",
    password: "",
    token: "",
    errorMsg: "",
    payload: {
      username: "",
      name: "",
      iat: 0,
      expiry: 0
    }
  };
  initialState.notifyModel = {
    message: "",
    level: "",
    hidden: true
  };
  initialState.quoteModel = "";
}

var elmApp = Elm.Main.fullscreen(initialState);

elmApp.ports.storeModel.subscribe(function(state) {
  localStorage.setItem('yadda-model', JSON.stringify(state));
});

elmApp.ports.removeModel.subscribe(function() {
  localStorage.removeItem('yadda-model');
});
