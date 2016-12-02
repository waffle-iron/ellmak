import _ from 'lodash'
import store from '../redux/store'
import { error, warn } from '../utils/logger'

const findByUsername = (username) => {
  return new Promise((resolve, reject) => {
    const db = store.getState().db

    if (db && !_.isEmpty(db.conn)) {
      const conn = db.conn
      const usersCollection = conn.collection('users')

      usersCollection.findOne({'username': username}, (err, doc) => {
        if (err) {
          error('User %s not found: %j', username, err)
          reject('User not found')
        } else if (!_.isEmpty(doc)) {
          resolve(doc)
        } else {
          warn('User %s not found', username)
          reject('No user documents found')
        }
      })
    } else {
      warn('Database not valid')
      warn('User %s not found', username)
      reject('User not found')
    }
  })
}

const findIdByUsername = (username) => {
  return new Promise((resolve, reject) => {
    const db = store.getState().db

    if (db && !_.isEmpty(db.conn)) {
      const conn = db.conn
      const usersCollection = conn.collection('users')

      usersCollection.findOne({'username': username}, (err, doc) => {
        if (err) {
          error('User %s not found: %j', username, err)
          reject('User not found')
        } else if (!_.isEmpty(doc)) {
          resolve(doc._id)
        } else {
          warn('User %s not found', username)
          reject('No user documents found')
        }
      })
    } else {
      warn('Database not valid')
      warn('User %s not found', username)
      reject('User not found')
    }
  })
}

export { findByUsername, findIdByUsername }
