// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
export const YADDA_DB_CONNECTED = 'yadda/db/connected'
export const YADDA_DB_DISCONNECTED = 'yadda/db/disconnect'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
export function connected (db) {
  return {
    type: YADDA_DB_CONNECTED,
    db: db
  }
}

export function disonnected () {
  return {
    type: YADDA_DB_DISCONNECTED
  }
}

// ----------------------------------------------------------------------
// Exported Actions, useful for use with bindActionCreators
// ----------------------------------------------------------------------
export const databaseActions = {
  connected,
  disonnected
}

// ----------------------------------------------------------------------
// Action Handlers
// ----------------------------------------------------------------------
const ACTION_HANDLERS = {
  [YADDA_DB_CONNECTED]: (state, action) => {
    return { ...state, db: action.db }
  },
  [YADDA_DB_DISCONNECTED]: (state, action) => {
    return initialState
  }
}

// ----------------------------------------------------------------------
// Initial Database State
// ----------------------------------------------------------------------
const initialState = {
  db: {}
}

// ----------------------------------------------------------------------
// Reducer
// ----------------------------------------------------------------------
export default function reducer (state = initialState, action) {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}
