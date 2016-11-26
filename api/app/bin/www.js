import app from '../app'
import { createServer } from 'http'
import { error, info, trace } from '../utils/logger'
import { connect } from '../utils/mongo'

connect((err) => {
  if (err) {
    error('Unable to connect to MongoDB! %j', err)
    throw err
  }
  trace('Connected to MongoDB!')
})

/**
 * Get port from environment and store in Express.
 */
const port = ((val) => {
  const port = parseInt(val, 10)

  if (isNaN(port)) {
    // named pipe
    return val
  }

  if (port >= 0) {
    // port number
    return port
  }

  return false
})(process.env.PORT || '3000')
app.set('port', port)

/**
 * Create HTTP server.
 */
const server = createServer(app)

/**
 * Listen on provided port, on all network interfaces.
 */
server.listen(port)
server.on('error', (error) => {
  if (error.syscall !== 'listen') {
    throw error
  }

  const bind = typeof port === 'string'
    ? 'Pipe ' + port
    : 'Port ' + port

  // handle specific listen errors with friendly messages
  switch (error.code) {
    case 'EACCES':
      error('%s requires elevated privileges', bind)
      process.exit(1)
      break
    case 'EADDRINUSE':
      error('%s is already in use', bind)
      process.exit(1)
      break
    default:
      throw error
  }
})
server.on('listening', () => {
  const addr = server.address()
  const bind = typeof addr === 'string'
    ? 'pipe ' + addr
    : 'port ' + addr.port
  info('Listening on %s', bind)
})
