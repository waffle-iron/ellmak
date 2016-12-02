import { MongoClient as mongo } from 'mongodb'
import _ from 'lodash'
import store from '../redux/store'
import { databaseActions } from '../redux/db'

const connect = () => {
  return new Promise((resolve, reject) => {
    const { connected } = databaseActions
    const db = store.getState().db

    if (db) {
      if (_.isEmpty(db.conn)) {
        mongo.connect('mongodb://ellmakdb:27017/ellmak', (err, conn) => {
          if (err) reject('Unable to connect to ellmak database')
          conn.authenticate('ellmak', process.env.ELLMAK_DB_PASSWORD, (err, result) => {
            if (err) reject(err)
            if (result === true) {
              store.dispatch(connected(conn))
              resolve()
            } else {
              reject('Unable to authenticate to ellmak database')
            }
          })
        })
      } else {
        resolve()
      }
    } else {
      reject('redux database store not initialized properly')
    }
  })
}

const disconnect = () => {
  return new Promise((resolve, reject) => {
    const { disconnected } = databaseActions
    const db = store.getState().db

    if (db && !_.isEmpty(db.conn)) {
      db.conn.close((err, result) => {
        if (err) reject(err)
        store.dispatch(disconnected())
        resolve()
      })
    }
  })
}

export { connect, disconnect }
