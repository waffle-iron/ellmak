// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
export const ELLMAK_DB_CONNECTED = 'ellmak/db/connected'
export const ELLMAK_DB_DISCONNECTED = 'ellmak/db/disconnect'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
export function connected (conn) {
  return {
    type: ELLMAK_DB_CONNECTED,
    conn: conn
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
    return { ...state, conn: action.conn }
  },
  [ELLMAK_DB_DISCONNECTED]: (state, action) => {
    return initialState
  }
}

// ----------------------------------------------------------------------
// Initial Database State
// ----------------------------------------------------------------------
const initialState = {
  conn: {}
}

// ----------------------------------------------------------------------
// Reducer
// ----------------------------------------------------------------------
export default function reducer (state = initialState, action) {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}
