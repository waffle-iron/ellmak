import jwt from 'jsonwebtoken'

const messageHandler = (message, flags, resolve, reject) => {
  if (message !== null) {
    if (message === 'heartbeat') {
      resolve(message)
    } else {
      try {
        const parsed = JSON.parse(message)
        const { token, msg } = parsed

        jwt.verify(token, process.env.ELLMAK_JWT_SECRET, (err, decoded) => {
          if (err) {
            reject(err)
          } else {
            resolve(JSON.stringify({msg: 'Valid Token: ' + msg}))
          }
        })
      } catch (e) {
        reject('invalid message json')
      }
    }
  } else {
    reject('null message')
  }
}

export default messageHandler
