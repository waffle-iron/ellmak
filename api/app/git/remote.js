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
    return repo.getRemotes().then(remoteNames => {
      const remotesPromises = remoteNames.map(v => repo.getRemote(v))
      Promise.all(remotesPromises).then(remotes => {
        const fetches = remotes.map(v => {
          return () => {
            return v.fetch(null, fetchOpts, '')
          }
        })

        fetches.reduce((chained, nextPromise) => {
          return chained.then(nextPromise)
        }, Promise.resolve()).then(() => resolve(repo)).catch(err => reject(err))
      }).catch(err => reject(err))
    }).catch(err => reject(err))
  })
}

export { fetchAll }
