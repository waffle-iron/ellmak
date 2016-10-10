var express = require('express');
var router = express.Router();

// Base App Routes
router.get('/', function(req, res) {
  res.send(JSON.stringify({version: 'yadda-api 0.1.0'}));
});

module.exports = router;
