'use strict';

require('./styles/core.scss');
require('./index.html');

if (__DEV__) {
  console.info('[YADDA-UI]', 'Running dev environment')
}

if (__PROD__) {
  console.warn('[YADDA-UI]', 'Running production environment')
}

var Elm = require('./Main');

var storedState = localStorage.getItem('yadda-model');
var initialState = storedState ? JSON.parse(storedState) : null;

var elmApp = Elm.Main.fullscreen(initialState);

elmApp.ports.storeModel.subscribe(function(state) {
  console.log('State: ', state)
  localStorage.setItem('yadda-model', JSON.stringify(state));
});

elmApp.ports.removeModel.subscribe(function() {
  localStorage.removeItem('yadda-model');
});
