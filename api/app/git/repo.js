import Git from 'nodegit'
import path from 'path'
import { error, info } from '../utils/logger'
import _ from 'lodash'

const cloneOptions = {
  fetchOpts: {
    callbacks: {
      certificateCheck: () => {
        return 1
      },
      credentials: (url, username, allowedTypes, payload) => {
        return Git.Cred.sshKeyNew(
          username,
          '/data/ssh/id_rsa.pub',
          '/data/ssh/id_rsa',
          ''
        )
      }
    }
  }
}

const open = (repoDoc) => {
  return new Promise((resolve, reject) => {
    const repoPath = path.join(process.env.ELLMAK_REPO_PATH, repoDoc.shortName)

    Git.Repository.open(repoPath).then((repo) => {
      checkRemotes(repoDoc, repo).then((repo) => {
        resolve(repo)
      }).catch((err) => {
        error(err)
        reject('Unable to verify remotes')
      })
    }).catch((err) => {
      error(err)
      Git.Clone(repoDoc.remotes['origin'], repoPath, cloneOptions).then((repo) => {
        checkRemotes(repoDoc, repo).then((repo) => {
          resolve(repo)
        }).catch((err) => {
          error(err)
          reject('Unable to verify remotes')
        })
      }).catch((err) => {
        error(err)
        reject('Unable to clone repository')
      })
    })
  })
}

const checkRemotes = (repoDoc, repo) => {
  return new Promise((resolve, reject) => {
    repo.getRemotes().then((remotes) => {
      const diff = _.difference(Object.keys(repoDoc.remotes), Object.values(remotes))
      diff.map((name) => {
        const url = repoDoc.remotes[name]
        Git.Remote.create(repo, name, url).then((remote) => {
          info('Remote %s at %s added', name, url)
        }).catch((err) => {
          error(err)
          reject('Unable to create remote')
        })
      })
      resolve(repo)
    }).catch((err) => {
      error(err)
      reject('Unable to lookup remotes')
    })
  })
}

export { cloneOptions, open }
