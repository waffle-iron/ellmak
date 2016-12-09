import _ from 'lodash'
import reducers from './reducers'
import { createStore } from 'redux'
import { trace } from '../utils/logger'

const store = createStore(reducers)

const select = (state) => {
  return state.sessions
}

let currentValue
const unsubscribe = store.subscribe(() => {
  let previousValue = currentValue || {}
  currentValue = select(store.getState())

  if (previousValue && previousValue !== currentValue) {
    const usernames = getObjectDiff(previousValue, currentValue)
    usernames.forEach(username => {
      logSession(currentValue[username])
    })
  }
})

const logSession = (session) => {
  trace('{')
  trace(`  userId: '${session.userId}',`)
  trace(`  uuid:   '${session.uuid}',`)
  if (_.isEmpty(session.ws)) {
    trace(`  ws:     {},`)
  } else {
    trace(`  ws:     [object Object],`)
  }
  trace('}')
}

/*
 * Compare two objects by reducing an array of keys in obj1, having the
 * keys in obj2 as the intial value of the result. Key points:
 *
 * - All keys of obj2 are initially in the result.
 *
 * - If the loop finds a key (from obj1, remember) not in obj2, it adds
 *   it to the result.
 *
 * - If the loop finds a key that are both in obj1 and obj2, it compares
 *   the value. If it's the same value, the key is removed from the result.
 */
const getObjectDiff = (obj1, obj2) => {
  const diff = Object.keys(obj1).reduce((result, key) => {
    if (!obj2.hasOwnProperty(key)) {
      result.push(key)
    } else if (_.isEqual(obj1[key], obj2[key])) {
      const resultKeyIndex = result.indexOf(key)
      result.splice(resultKeyIndex, 1)
    }
    return result
  }, Object.keys(obj2))

  return diff
}

export { store as default, unsubscribe }
