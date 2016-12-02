import jwt from 'jsonwebtoken'
import Git from 'nodegit'
import store from '../redux/store'
import { wssActions } from '../redux/ws'
import { findByUsername } from '../db/users'
import { findByUserId } from '../db/repos'
import { error, info } from '../utils/logger'
import { open } from '../git/repo'

const messageHandler = (ws, message, flags) => {
  return new Promise((resolve, reject) => {
    try {
      const parsed = JSON.parse(message)
      const { token, username, uuid, msg } = parsed

      jwt.verify(token, process.env.ELLMAK_JWT_SECRET, (err, decoded) => {
        if (err) {
          reject(err)
        } else if (msg === 'authenticated') {
          const { addConnection } = wssActions
          store.dispatch(addConnection(username, uuid, ws))
          findByUsername(username).then((user) => {
            findByUserId(user._id).then((repoDocs) => {
              repoDocs.forEach((repoDoc) => {
                open(repoDoc).then((repo) => {
                  info('Opened %s', repoDoc.shortName)
                  const fetchOpts = new Git.FetchOptions()
                  const callbacks = new Git.RemoteCallbacks()
                  fetchOpts.callbacks = callbacks
                  callbacks.credentials = (url, username) => {
                    return Git.Cred.sshKeyNew(
                      username,
                      '/data/ssh/id_rsa.pub',
                      '/data/ssh/id_rsa',
                      ''
                    )
                  }
                  callbacks.transferProgress = (info) => {
                    return console.log(info)
                  }
                  repo.fetchAll(fetchOpts).then(() => {
                    info('Fetched all')
                    repo.getStatus().then((statuses) => {
                      info('Statuses', statuses)
                    })
                  }).catch((err) => {
                    error(err)
                  })
                })
              })
              resolve(JSON.stringify('activated repos'))
            }).catch((err) => {
              reject(err)
            })
          }).catch((err) => {
            reject(err)
          })
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
  })
}

export default messageHandler
