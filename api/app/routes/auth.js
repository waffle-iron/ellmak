import argon2 from 'argon2'
import express from 'express'
import jwt from 'jsonwebtoken'
import { error } from '../utils/logger'
import { findByUsername } from '../db/users'

const router = express.Router()

router.put('/', (req, res, next) => {
  const { username, token } = req.body

  if (!username || username.length === 0) {
    return res.status(400).send('username required')
  }

  if (!token || token.length === 0) {
    return res.status(400).send('token required')
  }

  findByUsername(username).then((doc) => {
    jwt.verify(token, process.env.ELLMAK_JWT_SECRET, (err, decoded) => {
      if (err) {
        error(err)
        return res.status(401).send('invalid token')
      } else {
        var token = jwt.sign(
          { username: username, name: doc.name },
          process.env.ELLMAK_JWT_SECRET,
          { algorithm: 'HS512', expiresIn: '10m' }
        )
        return res.status(200).json({id_token: token})
      }
    })
  }).catch((err) => {
    error(err)
    return res.status(401).send('Unable to refresh token for user')
  })
})

router.post('/', (req, res, next) => {
  const { username, password } = req.body

  if (!username) {
    return res.status(401).send('username required')
  }

  if (!password) {
    return res.status(401).send('password required')
  }

  findByUsername(username).then((doc) => {
    argon2.verify(doc.password, password).then((match) => {
      if (match) {
        var token = jwt.sign(
          { username: username, name: doc.name },
          process.env.ELLMAK_JWT_SECRET,
          { algorithm: 'HS512', expiresIn: '10m' }
        )
        return res.status(200).json({id_token: token})
      } else {
        return res.status(401).send('Invalid username/password combination')
      }
    })
  }).catch((err) => {
    error(err)
    return res.status(401).send('Unable to authenticate user')
  })
})

export default router
