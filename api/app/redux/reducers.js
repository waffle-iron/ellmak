import { combineReducers } from 'redux'
import db from './db'
import repos from './repos'
import ws from './ws'

export default combineReducers({
  db,
  repos,
  ws
})
