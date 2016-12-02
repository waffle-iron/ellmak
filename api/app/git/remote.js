import Git from 'nodegit'
import spitStats from './tp'

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
      throttle: 50,
      callback: spitStats
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
