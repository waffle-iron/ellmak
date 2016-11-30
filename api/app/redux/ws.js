// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
export const ELLMAK_WSS_SERVER = 'ellmak/wss/server'
export const ELLMAK_WSS_ADD_CONN = 'ellmak/wss/addconn'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
export function addServer (wss) {
  return {
    type: ELLMAK_WSS_SERVER,
    wss: wss
  }
}

export function addConnection (username, uuid, ws) {
  return {
    type: ELLMAK_WSS_ADD_CONN,
    username: username,
    uuid: uuid,
    ws: ws
  }
}

// ----------------------------------------------------------------------
// Exported Actions, useful for use with bindActionCreators
// ----------------------------------------------------------------------
export const wssActions = {
  addServer,
  addConnection
}

// ----------------------------------------------------------------------
// Action Handlers
// ----------------------------------------------------------------------
const ACTION_HANDLERS = {
  [ELLMAK_WSS_SERVER]: (state, action) => {
    return { ...state, wss: action.wss }
  },
  [ELLMAK_WSS_ADD_CONN]: (state, action) => {
    const connDetail = { uuid: action.uuid, conn: action.ws, lastUsed: Date.now() }
    const newConns = { ...state.wsconns, [action.username]: connDetail }
    return { ...state, wsconns: newConns }
  }
}

// ----------------------------------------------------------------------
// Initial Database State
// ----------------------------------------------------------------------
const initialState = {
  wss: {},
  wsconns: {}
}

// ----------------------------------------------------------------------
// Reducer
// ----------------------------------------------------------------------
export default function reducer (state = initialState, action) {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}
