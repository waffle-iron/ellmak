import express from 'express'
import store from '../redux/store'
import { logActions } from '../redux/log'
import { warn } from '../utils/logger'

const router = express.Router()

router.patch('/', (req, res, next) => {
  const { level } = req.body
  const { setLevel } = logActions
  var success = false
  switch (level) {
    case 'trace':
    case 'debug':
    case 'info':
    case 'warn':
    case 'error':
      store.dispatch(setLevel(level))
      success = true
      break
    default:
      warn(`Invalid level ${level} specified`)
      break
  }

  if (success) {
    return res.status(200).send(JSON.stringify('Updated successfully'))
  } else {
    return res.status(500).send(JSON.stringify('Unable to update level!'))
  }
})

export default router
