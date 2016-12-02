import Git from 'nodegit'
import { info } from '../utils/logger'

const fetchOpts = {
  callbacks: {
    credentials: (url, username) => {
      return Git.Cred.sshKeyNew(
        username,
        '/data/ssh/id_rsa.pub',
        '/data/ssh/id_rsa',
        ''
      )
    },
    transferProgress: {
      throttle: 0,
      callback: (stats) => {
        const proto = Object.getPrototypeOf(stats)
        return Object.keys(proto).map(k => console.log(`${k}: ${stats[k]()}`))
      }
    }
  }
}

const fetchAll = (repo) => {
  return new Promise((resolve, reject) => {
    repo.getRemotes().then(remoteNames => {
      const remotesPromises = remoteNames.map(v => repo.getRemote(v))
      Promise.all(remotesPromises).then(remotes => {
        const fetchPromises = remotes.map(v => v.fetch(null, fetchOpts, ''))
        Promise.all(fetchPromises).then(() => resolve()).catch(err => reject(err))
      }).catch(err => reject(err))
    }).catch(err => reject(err))
  })
}

export { fetchAll }
