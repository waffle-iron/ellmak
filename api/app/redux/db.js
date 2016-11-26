// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
export const ELLMAK_DB_CONNECTED = 'ellmak/db/connected'
export const ELLMAK_DB_DISCONNECTED = 'ellmak/db/disconnect'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
export function connected (db) {
  return {
    type: ELLMAK_DB_CONNECTED,
    db: db
  }
}

export function disonnected () {
  return {
    type: ELLMAK_DB_DISCONNECTED
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
  [ELLMAK_DB_CONNECTED]: (state, action) => {
    return { ...state, db: action.db }
  },
  [ELLMAK_DB_DISCONNECTED]: (state, action) => {
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
