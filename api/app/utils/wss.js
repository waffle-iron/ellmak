import store from '../redux/store'
import { wssActions } from '../redux/ws'
import { Server as WebSocketServer } from 'ws'
import { info } from '../utils/logger'
import messageHandler from '../ws/handler'

const startWss = (server) => {
  const { addServer } = wssActions
  const wss = new WebSocketServer({server: server})
  store.dispatch(addServer(wss))
  wss.on('connection', (ws) => {
    info('websocket connection open')
    info('clients:', wss.clients.length)

    ws.on('message', (data, flags) => {
      new Promise((resolve, reject) => {
        messageHandler(data, flags, resolve, reject)
      }).then((result) => {
        ws.send(result)
      }).catch((err) => {
        ws.send(JSON.stringify({err: err}))
      })
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
