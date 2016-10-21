var express = require('express');
var router = express.Router();

/* GET random quote */
router.get('/', function(req, res, next) {
  res.send(JSON.stringify({quote: 'This is a random quote!!!'}));
});

module.exports = router;
