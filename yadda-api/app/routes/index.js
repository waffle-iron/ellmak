import express from 'express'

const router = express.Router()

router.get('/', (req, res) => {
  res.send(JSON.stringify({version: 'yadda-api 0.1.0'}))
})

export default router
