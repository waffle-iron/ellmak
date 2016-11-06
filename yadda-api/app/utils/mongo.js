import { MongoClient as mongo } from 'mongodb'
import store from '../redux/store'
import { databaseActions } from '../redux/db'

const connect = (callback) => {
  const { connected } = databaseActions
  if (store.getState().db) return callback()

  mongo.connect('mongodb://yaddadb:27017/yaddadb', (err, db) => {
    if (err) return callback(err)
    store.dispatch(connected(db))
    callback()
  })
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
