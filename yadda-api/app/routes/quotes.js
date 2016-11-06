import express from 'express'

const router = express.Router()

router.get('/', (req, res, next) => {
  res.send(JSON.stringify({quote: 'This is a random quote!!!'}))
})

export default router
