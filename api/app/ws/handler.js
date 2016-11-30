import jwt from 'jsonwebtoken'
import store from '../redux/store'
import { wssActions } from '../redux/ws'

const messageHandler = (ws, message, flags, resolve, reject) => {
  try {
    const parsed = JSON.parse(message)
    const { token, username, uuid, msg } = parsed

    jwt.verify(token, process.env.ELLMAK_JWT_SECRET, (err, decoded) => {
      if (err) {
        reject(err)
      } else if (msg === 'authenticated') {
        const { addConnection } = wssActions
        store.dispatch(addConnection(username, uuid, ws))
        resolve(JSON.stringify('authenticated'))
      } else if (msg === 'heartbeat') {
        const { addConnection } = wssActions
        if ((username && username.length > 0) && (uuid && uuid.length > 0)) {
          store.dispatch(addConnection(username, uuid, ws))
        }
        resolve(JSON.stringify('heartbeat'))
      } else {
        resolve(JSON.stringify({msg: 'Valid Token: ' + msg}))
      }
    })
  } catch (e) {
    reject('invalid message json')
  }
}

export default messageHandler
