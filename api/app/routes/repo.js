import express from 'express'
import { warn } from '../utils/logger'
import store from '../redux/store'
import _ from 'lodash'

const router = express.Router()

router.get('/', (req, res, next) => {
  const dbStore = store.getState().db

  if (dbStore && !_.isEmpty(dbStore.db)) {
    const db = dbStore.db
    const reposCollection = db.collection('repos')
    reposCollection.find({}).toArray((err, docs) => {
      if (err) return next(err)
      res.status(200).send(docs)
    })
  } else {
    warn('Database not valid')
    res.status(500).send('Database not valid. Unable to store repo information')
    return
  }
})

router.post('/', (req, res, next) => {
  const { remotes, branches, frequency, shortName } = req.body
  const dbStore = store.getState().db

  if (dbStore && !_.isEmpty(dbStore.db)) {
    const db = dbStore.db
    const reposCollection = db.collection('repos')

    reposCollection.findAndModify(
      {shortName: shortName},
      [['_id', 'asc']],
      {$set: {
        remotes: remotes,
        branches: branches,
        frequency: frequency,
        shortName: shortName
      }},
      {upsert: true, new: true},
      (err, result) => {
        if (err) return next(err)
        const doc = result.value
        res.status(200).send(doc)
        return
      }
    )
  } else {
    warn('Database not valid')
    res.status(500).send('Database not valid. Unable to store repo information')
    return
  }
})

export default router