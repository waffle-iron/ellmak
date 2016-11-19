import express from 'express'
import { info } from '../utils/logger'

const router = express.Router()

router.post('/', (req, res, next) => {
  const { url, branches, frequency } = req.body

  info('URL:', url)
  info('Branches:', branches)
  info('Frequency:', frequency)

  return res.send(JSON.stringify({repo: 'Added'}))
})

export default router
