import jwt from 'jsonwebtoken'
import { trace } from '../utils/logger'

const messageHandler = (message, flags, resolve, reject) => {
  trace('Message:', message)

  if (message !== null) {
    if (message === 'heartbeat') {
      resolve(message)
    } else if (typeof message === 'object') {

    } else {
      reject('unknown mesage type')
    }
  } else {
    reject('null message')
  }
}

export default messageHandler
