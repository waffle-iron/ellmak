import Git from 'nodegit'
import path from 'path'
import { trace } from '../utils/logger'
import _ from 'lodash'
import spitStats from './tp'

const cloneOptions = {
  fetchOpts: {
    callbacks: {
      credentials: (url, username, allowedTypes, payload) => {
        return Git.Cred.sshKeyNew(
          username,
          '/data/ssh/id_rsa.pub',
          '/data/ssh/id_rsa',
          ''
        )
      },
      transferProgress: {
        throttle: 100,
        callback: spitStats
      }
    }
  }
}

const openOrClone = (repoDoc) => {
  return new Promise((resolve, reject) => {
    const repoPath = path.join(process.env.ELLMAK_REPO_PATH, repoDoc.shortName)
    Git.Repository.open(repoPath).then(repo => {
      return checkRemotes(repoDoc, repo)
    }).then(repo => resolve(repo)).catch(err => {
      trace(err)
      Git.Clone(repoDoc.remotes['origin'], repoPath, cloneOptions).then(repo => {
        return checkRemotes(repoDoc, repo)
      }).then(repo => resolve(repo)).catch(err => reject(err))
    })
  })
}

const checkRemotes = (repoDoc, repo) => {
  return new Promise((resolve, reject) => {
    repo.getRemotes().then(remotes => {
      const diff = _.difference(Object.keys(repoDoc.remotes), Object.values(remotes))
      const creates = diff.map(name => {
        return () => {
          return Git.Remote.create(repo, name, repoDoc.remotes[name])
        }
      })

      creates.reduce((chained, nextPromise) => {
        return chained.then(nextPromise)
      }, Promise.resolve()).then(() => {
        resolve(repo)
      }).catch(err => reject(err))
    }).catch(err => reject(err))
  })
}

export { cloneOptions, openOrClone }
