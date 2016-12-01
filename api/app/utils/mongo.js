import { MongoClient as mongo } from 'mongodb'
import store from '../redux/store'
import { databaseActions } from '../redux/db'
import _ from 'lodash'
import { error, trace } from '../utils/logger'

const connect = (callback) => {
  const { connected } = databaseActions
  var dbStore = store.getState().db

  if (dbStore) {
    if (_.isEmpty(dbStore.db)) {
      mongo.connect('mongodb://ellmakdb:27017/ellmak', (err, db) => {
        if (err) return callback(err)
        db.authenticate('ellmak', process.env.ELLMAK_DB_PASSWORD, (err, result) => {
          if (err) {
            error('Unable to authenticate to ellmak database:', err)
          } else if (result === true) {
            trace('Authenticated to ellmak database')
            store.dispatch(connected(db))
          } else {
            error('Unable to authenticate to ellmak database')
          }
          callback()
        })
        callback()
      })
    } else {
      return callback()
    }
  }
}

const disconnect = (callback) => {
  const { disconnected } = databaseActions
  const { db } = store.getState()
  if (db) {
    db.close((err, result) => {
      if (err) return callback(err)
      store.dispatch(disconnected())
      return callback()
    })
  }
}

export { connect, disconnect }
