import express from 'express'
import jwt from 'jsonwebtoken'
import store from '../redux/store'
import { debug, error, warn } from '../utils/logger'
import _ from 'lodash'

const router = express.Router()

router.post('/', (req, res, next) => {
  var username = req.body.username
  var password = req.body.password
  if (!username) {
    res.status(400).send('username required')
    return
  }

  if (!password) {
    res.status(400).send('password required')
    return
  }

  var dbStore = store.getState().db
  if (dbStore && !_.isEmpty(dbStore.db)) {
    var db = dbStore.db
    var usersCollection = db.collection('users')

    usersCollection.findOne({'username': username}, (err, doc) => {
      if (err) error('User %s not found: %j', username, err)
      debug('Doc: %j', doc)
    })
  } else {
    warn('Database not valid')
    warn('User %s not found', username)
  }

  var token = jwt.sign({ username: username }, process.env.YADDA_JWT_SECRET, { algorithm: 'HS512', expiresIn: '1h' })
  res.status(200).json({id_token: token})
})

export default router
