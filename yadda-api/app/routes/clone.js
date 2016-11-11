import express from 'express'
import path from 'path'
import git from 'nodegit'
import { info } from '../utils/logger'

const router = express.Router()

router.get('/', (req, res, next) => {
  const { repo } = req.query
  const cloneURL = 'https://github.com/nodegit/test'
  const repoPath = path.join('/data/repo', repo)

  const cloner = git.Clone(cloneURL, repoPath, {})

  cloner.then((repo) => {
    info('Is the repository bare? %s', Boolean(repo.isBare()))
    return res.send(JSON.stringify({clone: 'Cloned'}))
  }).catch((err) => {
    if (err) info('Error:', err)
    return next(err)
  })
})

export default router
