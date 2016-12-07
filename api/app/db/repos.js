import _ from 'lodash'
import store from '../redux/store'

const findByUserId = (userId) => {
  return new Promise((resolve, reject) => {
    const db = store.getState().db

    if (db && !_.isEmpty(db.conn)) {
      const conn = db.conn
      const reposCollection = conn.collection('repos')
      reposCollection.find({usersId: userId}).toArray((err, docs) => {
        if (err) reject(err)
        resolve(docs)
      })
    } else {
      reject('Database not valid. Unable to lookup repository information')
    }
  })
}

const upsertByShortName = (id, body) => {
  return new Promise((resolve, reject) => {
    const db = store.getState().db

    if (db && !_.isEmpty(db.conn)) {
      const conn = db.conn
      const reposCollection = conn.collection('repos')
      const { remotes, refs, frequency, shortName } = body

      reposCollection.findAndModify(
        {shortName: shortName, usersId: id},
        [['_id', 'asc']],
        {$set: {
          remotes: remotes,
          refs: refs,
          frequency: frequency,
          shortName: shortName,
          usersId: id
        }},
        {upsert: true, new: true},
        (err, result) => {
          if (err) reject(err)
          const doc = result.value
          resolve(doc)
        }
      )
    } else {
      reject('Database not valid. Unable to upsert repository information')
    }
  })
}

const updateRefs = (id, shortName, refs) => {
  return new Promise((resolve, reject) => {
    const db = store.getState().db

    if (db && !_.isEmpty(db.conn)) {
      const conn = db.conn
      const reposCollection = conn.collection('repos')

      reposCollection.findAndModify(
        {shortName: shortName, usersId: id},
        [['_id', 'asc']],
        {$set: { refs: refs }},
        {upsert: true},
        (err, result) => {
          if (err) reject(err)
          const doc = result.value
          resolve(doc)
        }
      )
    } else {
      reject('Database not valid. Unable to upsert repository information')
    }
  })
}

export { findByUserId, updateRefs, upsertByShortName }
