import { findByUsername } from '../db/users'
import { findByUserId } from '../db/repos'
import { open } from '../git/repo'
import { fetchAll } from '../git/remote'
import { error, trace } from '../utils/logger'

const checkRefs = (username) => {
  return new Promise((resolve, reject) => {
    findByUsername(username).then(user => {
      findByUserId(user._id).then(repoDocs => {
        repoDocs.forEach(repoDoc => {
          trace(`Opening ${repoDoc.shortName}`)
          open(repoDoc).then(repo => {
            fetchAll(repo).then(repo => {
              repo.getReferences(3).then(refsArr => {
                refsArr.forEach(ref => {
                  repo.getReferenceCommit(ref).then(commit => {
                    updateRef(username, repoDoc.branches, ref, commit)
                  }).catch(err => error(err))
                })
                resolve()
              }).catch(err => error(err))
            }).catch(err => error(err))
          }).catch(err => error(err))
        })
      }).catch(err => reject(err))
    }).catch(err => reject(err))
  })
}

const updateRef = (username, branches, ref, commit) => {
  const regexes = branches.map(branch => new RegExp('.*' + branch + '.*'))

  for (var i = 0; i < regexes.length; i++) {
    const matchArr = regexes[i].exec(ref.toString())
    if (matchArr) {
      trace(`Matched ${branches[i]} with ${ref.toString()}`)
    }
  }
}

export { checkRefs }
