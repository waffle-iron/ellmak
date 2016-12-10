import { combineReducers } from 'redux'
import db from './db'
import intervals from './intervals'
import log from './log'
import repos from './repos'
import sessions from './sessions'
import ws from './ws'

export default combineReducers({
  db,
  intervals,
  log,
  repos,
  sessions,
  ws
})
