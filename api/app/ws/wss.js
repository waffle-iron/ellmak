import store from '../redux/store'
import { wssActions } from '../redux/ws'
import { Server as WebSocketServer } from 'ws'
import { trace } from '../utils/logger'
import messageHandler from '../ws/handler'

const startWss = (server) => {
  const { addServer } = wssActions
  const wss = new WebSocketServer({server: server})
  store.dispatch(addServer(wss))
  wss.on('connection', (ws) => {
    trace('websocket connection open')
    trace('clients:', wss.clients.length)

    ws.on('message', (data, flags) => {
      trace('message received')
      messageHandler(ws, data, flags).then((result) => {
        ws.send(result)
      }).catch((err) => {
        ws.send(JSON.stringify({err: err}))
      })
    })

    ws.on('close', () => {
      trace('websocket connection closed')
      trace('clients: ', wss.clients.length)
    })
  })
}

const broadcast = (data, callback) => {
  const wss = store.getState().wss
  const { clients } = wss

  if (clients) {
    clients.forEach((client) => {
      client.send(data)
    })
  }
}

export { broadcast, startWss }
