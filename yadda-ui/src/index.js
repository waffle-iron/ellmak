'use strict';

require('./styles/core.scss');
require('./index.html');
var Elm = require('./Main');

var storedState = localStorage.getItem('yadda-model');
var initialState = storedState ? JSON.parse(storedState) : null;

var elmApp = Elm.Main.fullscreen(initialState);

elmApp.ports.storeModel.subscribe(function(state) {
  localStorage.setItem('yadda-model', JSON.stringify(state));
});

elmApp.ports.removeModel.subscribe(function(state) {
  localStorage.setItem('yadda-model', JSON.stringify(state));
});
