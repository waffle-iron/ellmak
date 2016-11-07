import express from 'express'

const router = express.Router()

router.get('/', (req, res) => {
  res.send(JSON.stringify({name: 'yadda-api', version: 'v0.1.0'}))
})

export default router
