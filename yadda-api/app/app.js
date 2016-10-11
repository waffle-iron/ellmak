var express = require('express');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var cors = require('cors');
var routes = require('./routes/index');
var log = require('./utils/logger');
var db = require('./utils/mongo');

var router = express.Router();
var app = express();

log.banner();

var whitelist = process.env.YADDA_CORS_WHITELIST.split(',');
var corsOptions = {
  origin: true,
  // origin: function(origin, callback){
  //   var originIsWhitelisted = whitelist.indexOf(origin) !== -1;
  //   callback(null, originIsWhitelisted);
  // },
  // credentials: true,
  // methods: "GET,HEAD,OPTIONS,PUT,PATCH,POST,DELETE",
  // allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions))
app.options('*', cors());

app.use(logger('combined'));
app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({limit: '50mb', extended: false}));
app.use(cookieParser());

app.use('/api/v1', router);

router.use('/', routes);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: {}
  });
});


module.exports = app;
