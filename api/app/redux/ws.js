// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
export const ELLMAK_WSS_SERVER = 'ellmak/wss/server'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
export function addServer (wss) {
  return {
    type: ELLMAK_WSS_SERVER,
    wss: wss
  }
}

// ----------------------------------------------------------------------
// Exported Actions, useful for use with bindActionCreators
// ----------------------------------------------------------------------
export const wssActions = {
  addServer
}

// ----------------------------------------------------------------------
// Action Handlers
// ----------------------------------------------------------------------
const ACTION_HANDLERS = {
  [ELLMAK_WSS_SERVER]: (state, action) => {
    return { ...state, wss: action.wss }
  }
}

// ----------------------------------------------------------------------
// Initial Database State
// ----------------------------------------------------------------------
const initialState = {
  wss: {}
}

// ----------------------------------------------------------------------
// Reducer
// ----------------------------------------------------------------------
export default function reducer (state = initialState, action) {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}
