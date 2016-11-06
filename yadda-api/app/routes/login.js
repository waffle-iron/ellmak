import express from 'express'
import jwt from 'jsonwebtoken'

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

  var token = jwt.sign({ username: username }, process.env.YADDA_JWT_SECRET, { algorithm: 'HS512', expiresIn: '1h' })
  res.status(200).json({id_token: token})
})

export default router
