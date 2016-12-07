import _ from 'lodash'
import moment from 'moment-timezone'
import { findByUsername } from '../db/users'
import { findByUserId, updateRefs } from '../db/repos'
import { open } from '../git/repo'
import { fetchAll } from '../git/remote'
import { error, trace } from '../utils/logger'

var intervals = {}

const updateInterval = (username, repoDoc) => {
  const { frequency, shortName } = repoDoc
  const key = username + '-' + shortName
  const currVal = intervals[key]

  if (currVal && !_.isEmpty(currVal)) {
    if (currVal.frequency !== frequency) {
      trace('Cancelling old inverval, setting up another due to new frequency')
      clearInterval(currVal.intRef)
      currVal.intRef = setInterval(checkRefs, 60000, username)
    }
  } else {
    intervals[key] = {
      intRef: setInterval(checkRefs, 60000, username),
      frequency: frequency
    }
  }
}

const checkRefs = (username) => {
  return new Promise((resolve, reject) => {
    findByUsername(username).then(user => {
      findByUserId(user._id).then(repoDocs => {
        repoDocs.forEach(repoDoc => {
          open(repoDoc).then(repo => {
            fetchAll(repo).then(repo => {
              repo.getReferences(3).then(refsArr => {
                refsArr.forEach(ref => {
                  repo.getReferenceCommit(ref).then(commit => {
                    updateRef(username, user._id, repoDoc, ref, commit)
                  }).catch(err => reject(err))
                })
                updateInterval(username, repoDoc)
                resolve()
              }).catch(err => reject(err))
            }).catch(err => reject(err))
          }).catch(err => reject(err))
        })
      }).catch(err => reject(err))
    }).catch(err => reject(err))
  })
}

const updateRef = (username, id, repoDoc, ref, commit) => {
  const { refs, shortName } = repoDoc
  const regexes = refs.map(refObj => new RegExp('.*' + refObj.ref + '.*'))

  for (var i = 0; i < regexes.length; i++) {
    const matchArr = regexes[i].exec(ref.toString())
    if (matchArr) {
      const commitTime = moment(commit.timeMs())
      const lastUpdatedTime = moment(refs[i].lastUpdated)

      if (commitTime.isAfter(lastUpdatedTime)) {
        trace(`Updating ${refs[i].ref} with new value`)
        refs[i].lastUpdated = commit.timeMs()
        updateRefs(id, shortName, refs).catch(err => error(err))
      }
      break
    }
  }
}

export { checkRefs }
