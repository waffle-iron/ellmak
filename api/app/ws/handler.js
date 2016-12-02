import jwt from 'jsonwebtoken'
import store from '../redux/store'
import { wssActions } from '../redux/ws'
import { findByUsername } from '../db/users'
import { findByUserId } from '../db/repos'
import { error, info } from '../utils/logger'
import { open } from '../git/repo'
import { fetchAll } from '../git/remote'

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
                  fetchAll(repo).then(() => {
                    repo.getReferences(3).then(refsArr => {
                      refsArr.forEach(ref => {
                        repo.getReferenceCommit(ref).then(commit => {
                          console.log(`${ref}: ${commit} at ${commit.date()}`)
                        })
                      })
                    })
                  }).catch(err => error(err))
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
