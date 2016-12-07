import _ from 'lodash'
import moment from 'moment-timezone'
import mailer from 'nodemailer'
import { findByUsername } from '../db/users'
import { findByUserId, updateRefs } from '../db/repos'
import { open } from '../git/repo'
import { fetchAll } from '../git/remote'
import store from '../redux/store'
import { intervalsActions } from '../redux/intervals'
import { error, trace } from '../utils/logger'

const secondsRe = /^(\d+)s$/
const minutesRe = /^(\d+)m$/
const hoursRe = /^(\d+)h$/
const daysRe = /^(\d+)d$/
const transporter = mailer.createTransport('smtps://jason.g.ozias%40gmail.com:ulvjszkcsouvwjln@smtp.gmail.com')
const mailOptions = {
  from: '"Jason Ozias" <jason.g.ozias@gmail.com>',
  to: 'jason.g.ozias@gmail.com',
  subject: 'Ellmak Notification',
  html: '<h1>Testing</h1>'
}
const applyFactor = (frequency, regex, factor) => {
  const matches = frequency.match(regex)

  if (matches && matches.length === 2) {
    return (parseInt(matches[1]) * factor)
  }
}

const toMs = (frequency) => {
  var ms = 1800000 // 30 minutes is fallback

  if (secondsRe.test(frequency)) {
    ms = applyFactor(frequency, secondsRe, 1000)
  } else if (minutesRe.test(frequency)) {
    ms = applyFactor(frequency, minutesRe, 60000)
  } else if (hoursRe.test(frequency)) {
    ms = applyFactor(frequency, hoursRe, 3600000)
  } else if (daysRe.test(frequency)) {
    ms = applyFactor(frequency, daysRe, 86400000)
  }

  trace(`Frequency (${frequency}): ${ms} ms`)
  return ms
}

const updateInterval = (username, repoDoc) => {
  const { frequency, shortName } = repoDoc
  const { intervals } = store.getState().intervals
  const key = username + '-' + shortName
  const currVal = intervals[key]

  if (currVal && !_.isEmpty(currVal)) {
    if (currVal.frequency !== frequency) {
      const { add, remove } = intervalsActions
      trace('Clearing old inverval, setting up another due to new frequency')
      clearInterval(currVal.intRef)
      store.dispatch(remove(key))
      store.dispatch(add(key, {
        intRef: setInterval(checkRefs, toMs(frequency), username),
        frequency: frequency
      }))
    }
  } else {
    const { add } = intervalsActions
    store.dispatch(add(key, {
      intRef: setInterval(checkRefs, toMs(frequency), username),
      frequency: frequency
    }))
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
        updateRefs(id, shortName, refs).then(() => {
          transporter.sendMail(mailOptions, (err, info) => {
            if (err) {
              error(err)
            } else {
              trace(`Message Sent: ${info.response}`)
            }
          })
        }).catch(err => error(err))
      }
      break
    }
  }
}

export { checkRefs }
