import { combineReducers } from 'redux'
import db from './db'
import intervals from './intervals'
import repos from './repos'
import sessions from './sessions'
import ws from './ws'

export default combineReducers({
  db,
  intervals,
  repos,
  sessions,
  ws
})
