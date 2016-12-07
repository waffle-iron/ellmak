import { combineReducers } from 'redux'
import db from './db'
import intervals from './intervals'
import repos from './repos'
import ws from './ws'

export default combineReducers({
  db,
  intervals,
  repos,
  ws
})
