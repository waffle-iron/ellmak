import app from '../app'
import { createServer } from 'http'
import { error, info } from '../utils/logger'
import { connect } from '../db/db'
import { startWss } from '../ws/wss'

connect().then(() => {
  info('Connected to mongo')

  // Setup port
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

  const server = createServer(app)
  startWss(server)

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
}).catch((err) => {
  error('Unable to connect to MongoDB! %j', err)
  process.exit(1)
})
