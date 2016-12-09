import jwt from 'jsonwebtoken'
import store from '../redux/store'
import { findByUserId } from '../db/repos'
import { findByUsername } from '../db/users'
import { checkRef, updateInterval } from '../git/refs'
import { sessionActions } from '../redux/sessions'

const createSession = (uuid, username, ws) => {
  return new Promise((resolve, reject) => {
    const { addUuid, addWebSocket, createSession } = sessionActions
    store.dispatch(createSession(username))
    store.dispatch(addUuid(username, uuid))
    store.dispatch(addWebSocket(username, ws))
    updateSession(username, true).then(() => resolve()).catch(err => reject(err))
  })
}

const updateSession = (username, check) => {
  return new Promise((resolve, reject) => {
    findByUsername(username).then(userDoc => {
      const { addUserId } = sessionActions
      store.dispatch(addUserId(username, userDoc._id))
      return findByUserId(userDoc._id)
    }).then(repoDocs => {
      repoDocs.forEach(repoDoc => {
        updateInterval(username, repoDoc)
        if (check) {
          checkRef(username, repoDoc)
        }
      })

      resolve()
    }).catch(err => reject(err))
  })
}

const messageHandler = (ws, message, flags) => {
  return new Promise((resolve, reject) => {
    try {
      const parsed = JSON.parse(message)
      const { token, username, uuid, msg } = parsed

      if (!username || username.length === 0) {
        reject('invalid username')
      } else if (!uuid || uuid.length === 0) {
        reject('invalid uuid')
      } else {
        jwt.verify(token, process.env.ELLMAK_JWT_SECRET, (err, decoded) => {
          if (err) {
            reject(err)
          } else if (msg === 'authenticated' || msg === 'heartbeat') {
            const session = store.getState().sessions[username]

            if (!session) {
              createSession(uuid, username, ws).then(() => resolve(JSON.stringify(msg))).catch(err => reject(err))
            } else {
              updateSession(username).then(() => resolve(JSON.stringify(msg))).catch(err => reject(err))
            }
          } else {
            resolve(JSON.stringify('Valid Token: ' + msg))
          }
        })
      }
    } catch (e) {
      reject('invalid message json')
    }
  })
}

export default messageHandler
