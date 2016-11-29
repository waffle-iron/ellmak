import { combineReducers } from 'redux'
import db from './db'
import ws from './ws'

export default combineReducers({
  db,
  ws
})
