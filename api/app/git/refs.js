import _ from 'lodash'
import express from 'express'
import moment from 'moment-timezone'
import mailer from 'nodemailer'
import Git from 'nodegit'
import store from '../redux/store'
import spitStats from './tp'
import { flaggedRefs, updateRefs } from '../db/repos'
import { openOrClone } from '../git/repo'
import { intervalsActions } from '../redux/intervals'
import { error, trace, warn } from '../utils/logger'

const app = express()

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
const secondsRe = /^(\d+)s$/
const minutesRe = /^(\d+)m$/
const hoursRe = /^(\d+)h$/
const daysRe = /^(\d+)d$/
const transporter = mailer.createTransport(process.env.ELLMAK_SMTP_HOST)
const defaultMailOpts = {
  from: process.env.ELLMAK_SMTP_FROM,
  to: process.env.ELLMAK_SMTP_TO
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

  return ms
}

const updateInterval = (username, repoDoc) => {
  const { frequency, shortName } = repoDoc
  const { intervals } = store.getState().intervals
  const key = username + '-' + shortName
  const currVal = intervals[key]
  const session = store.getState().sessions[username]

  if (currVal && !_.isEmpty(currVal)) {
    if (currVal.frequency !== frequency) {
      const { add, remove } = intervalsActions
      warn('Clearing old inverval, setting up another due to new frequency')
      clearInterval(currVal.intRef)
      store.dispatch(remove(key))
      trace(`checking repo '${shortName}' for user '${session.userId}' every ${frequency}`)
      store.dispatch(add(key, {
        intRef: setInterval(checkRef, toMs(frequency), username, repoDoc),
        frequency: frequency
      }))
    }
  } else {
    const { add } = intervalsActions
    trace(`checking repo '${shortName}' for user '${session.userId}' every ${frequency}`)
    store.dispatch(add(key, {
      intRef: setInterval(checkRef, toMs(frequency), username, repoDoc),
      frequency: frequency
    }))
  }
}

const checkRef = (username, repoDoc) => {
  openOrClone(repoDoc).then(repo => {
    repo.fetchAll(fetchOpts).then(() => {
      repo.getReferences(3).then(refsArr => {
        const refs = refsArr.map(ref => {
          return () => {
            if (ref.isBranch() === 1 || ref.isRemote() === 1) {
              return repo.getReferenceCommit(ref).then(commit => {
                return updateRef(username, repoDoc, ref, commit)
              }).catch(err => {
                error(err)
                return Promise.reject()
              })
            } else {
              return Promise.resolve()
            }
          }
        })

        refs.reduce((chained, nextPromise) => { return chained.then(nextPromise) }, Promise.resolve()).then(() => {
          const session = store.getState().sessions[username]
          const { userId } = session
          const { shortName } = repoDoc

          flaggedRefs(userId, shortName).then(doc => {
            const refs = doc.refs
            const flaggedRefs = refs.filter(ref => { return ref.flagged })

            if (flaggedRefs.length > 0) {
              const bodyPrefix = `<h2>${shortName}</h2><p><ul>`
              const bodySuffix = '</ul></p>'
              var body = ''
              const version = '<h4>ellmak api ' + API_VERSION +
                ', ellmak ui ' + UI_VERSION + ' (' + app.get('env') + ')</h4>'

              flaggedRefs.forEach(ref => {
                const lastUpdatedTime = moment(ref.lastUpdated).tz('America/New_York')
                body += `<li>${ref.ref}: commit at ${lastUpdatedTime.format()}</li>`
              })

              const mailOpts = Object.assign({}, defaultMailOpts, {
                subject: `[ellmak] ${shortName}`,
                html: bodyPrefix + body + bodySuffix + version
              })
              transporter.sendMail(mailOpts, (err, info) => {
                if (err) {
                  error(err)
                } else {
                  trace(`email sent: ${info.response}`)
                  const newRefs = refs.map(ref => {
                    ref.flagged = false
                    return ref
                  })
                  updateRefs(userId, shortName, newRefs).catch(err => error(err))
                }
              })
            }
          }).catch(err => error(err))
        }).catch(err => error(err))
      }).catch(err => error(err))
    }).catch(err => error(err))
  }).catch(err => error(err))
}

const updateRef = (username, repoDoc, ref, commit) => {
  return new Promise((resolve, reject) => {
    const session = store.getState().sessions[username]
    const { refs, shortName } = repoDoc
    const regexes = refs.map(refObj => new RegExp('.*' + refObj.ref + '.*'))

    for (var i = 0; i < regexes.length; i++) {
      const matchArr = regexes[i].exec(ref.toString())
      if (matchArr) {
        trace(`checking '${ref.toString()}' on repo '${shortName}' for user '${session.userId}'`)
        const commitTime = moment(commit.timeMs())
        const lastUpdatedTime = moment(refs[i].lastUpdated)

        if (commitTime.isAfter(lastUpdatedTime)) {
          trace(`'${ref.toString()}' has more recent commits`)
          refs[i].lastUpdated = commit.timeMs()
          refs[i].flagged = true
          updateRefs(session.userId, shortName, refs).catch(err => reject(err))
        }
        break
      }
    }
    resolve()
  })
}

export { checkRef, updateInterval }
