import express from 'express'
import cors from 'cors'
import jwt from 'express-jwt'
import logger from 'morgan'
import cookieParser from 'cookie-parser'
import bodyParser from 'body-parser'
import routes from './routes/index'
import login from './routes/login'
import clone from './routes/clone'
import repo from './routes/repo'
import { banner, error } from './utils/logger'

const router = express.Router()
const app = express()

banner()

const whitelist = process.env.ELLMAK_CORS_WHITELIST.split(',')
const corsOptions = {
  origin: (origin, callback) => {
    const originIsWhitelisted = whitelist.indexOf(origin) !== -1
    callback(null, originIsWhitelisted)
  },
  credentials: true,
  methods: 'GET,HEAD,OPTIONS,PUT,PATCH,POST,DELETE',
  allowedHeaders: ['Content-Type', 'Authorization']
}

app.use(cors(corsOptions))
app.options('*', cors())

app.use(jwt({secret: process.env.ELLMAK_JWT_SECRET}).unless({
  path: ['/api/v1', '/api/v1/login']
}))

app.use(logger('combined'))
app.use(bodyParser.json({limit: '50mb'}))
app.use(bodyParser.urlencoded({limit: '50mb', extended: false}))
app.use(cookieParser())

app.use('/api/v1', router)

router.use('/', routes)
router.use('/login', login)
router.use('/clone', clone)
router.use('/repo', repo)

// catch 404 and forward to error handler
app.use((req, res, next) => {
  var err = new Error('Not Found')
  err.status = 404
  next(err)
})

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use((err, req, res, next) => {
    error(err)
    res.status(err.status || 500)
    res.send(JSON.stringify({
      message: err.message,
      error: err
    }))
  })
}

// production error handler
// no stacktraces leaked to user
app.use((err, req, res, next) => {
  error(err)
  res.status(err.status || 500)
  res.send(JSON.stringify({
    message: err.message,
    error: {}
  }))
})

export default app
