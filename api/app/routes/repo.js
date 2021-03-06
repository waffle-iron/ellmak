import express from 'express'
import { findIdByUsername } from '../db/users'
import { findByUserId, upsertByShortName } from '../db/repos'
import { openOrClone } from '../git/repo'
import { error } from '../utils/logger'

const router = express.Router()

router.get('/', (req, res, next) => {
  const { username } = req.query

  findIdByUsername(username).then((id) => {
    findByUserId(id).then((docs) => {
      return res.status(200).send(docs)
    }).catch((err) => {
      error(err)
      return res.status(500).send('Unable to lookup repository information for user')
    })
  }).catch((err) => {
    error('Unable to determine user:', err)
    return res.status(500).send('Unable to determine user')
  })
})

router.post('/', (req, res, next) => {
  const { username } = req.body

  findIdByUsername(username).then((id) => {
    upsertByShortName(id, req.body).then((doc) => {
      openOrClone(doc).catch(err => error('Unable to clone repo:', err))
      return res.status(200).send(doc)
    }).catch((err) => {
      error(err)
      return res.status(500).send('Unable to upsert repository information')
    })
  }).catch((err) => {
    error(err)
    return res.status(500).send('Unable to determine user')
  })
})

export default router
