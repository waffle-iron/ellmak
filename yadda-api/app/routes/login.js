import express from 'express'
import jwt from 'jsonwebtoken'
import store from '../redux/store'
import { error, warn } from '../utils/logger'
import _ from 'lodash'
import argon2 from 'argon2'

const router = express.Router()
// const hashOpts = {
//   timeCost: 10, memoryCost: 16, parallelism: 4
// }

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
      if (err) {
        error('User %s not found: %j', username, err)
        res.status(401).send('User not found')
        return
      } else {
        argon2.verify(doc.password, password).then(match => {
          if (match) {
            var token = jwt.sign(
              { username: username, name: doc.name },
              process.env.YADDA_JWT_SECRET,
              { algorithm: 'HS512', expiresIn: '1h' }
            )
            res.status(200).json({id_token: token})
            return
          } else {
            res.status(401).send('Invalid username/password combination')
            return
          }
        })
      }
    })
  } else {
    warn('Database not valid')
    warn('User %s not found', username)
    res.status(401).send('User not found')
    return
  }
})

export default router
