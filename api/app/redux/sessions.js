// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
export const ELLMAK_SESSION_CREATE = 'ellmak/session/create'
export const ELLMAK_SESSION_ADD_USERID = 'ellmak/session/add/userid'
export const ELLMAK_SESSION_ADD_UUID = 'ellmak/session/add/username'
export const ELLMAK_SESSION_ADD_WEBSOCKET = 'ellmak/session/add/websocket'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
const createSession = (userName) => {
  return {
    type: ELLMAK_SESSION_CREATE,
    userName: userName
  }
}

const addUserId = (userName, userId) => {
  return {
    type: ELLMAK_SESSION_ADD_USERID,
    userName: userName,
    userId: userId
  }
}

const addUuid = (userName, uuid) => {
  return {
    type: ELLMAK_SESSION_ADD_UUID,
    userName: userName,
    uuid: uuid
  }
}

const addWebSocket = (userName, ws) => {
  return {
    type: ELLMAK_SESSION_ADD_WEBSOCKET,
    userName: userName,
    ws: ws
  }
}

// ----------------------------------------------------------------------
// Exported Actions, useful for use with bindActionCreators
// ----------------------------------------------------------------------
const sessionActions = {
  addUserId,
  addUuid,
  addWebSocket,
  createSession
}

// ----------------------------------------------------------------------
// Action Handlers
// ----------------------------------------------------------------------
const ACTION_HANDLERS = {
  [ELLMAK_SESSION_CREATE]: (state, action) => {
    return {
      ...state,
      [action.userName]: {
        userId: '',
        uuid: '',
        ws: {}
      }
    }
  },
  [ELLMAK_SESSION_ADD_USERID]: (state, action) => {
    return { ...state, [action.userName]: { ...state[action.userName], userId: action.userId } }
  },
  [ELLMAK_SESSION_ADD_UUID]: (state, action) => {
    return { ...state, [action.userName]: { ...state[action.userName], uuid: action.uuid } }
  },
  [ELLMAK_SESSION_ADD_WEBSOCKET]: (state, action) => {
    return { ...state, [action.userName]: { ...state[action.userName], ws: action.ws } }
  }
}

// ----------------------------------------------------------------------
// Initial Database State
// ----------------------------------------------------------------------
const initialState = {}

// ----------------------------------------------------------------------
// Reducer
// ----------------------------------------------------------------------
const reducer = (state = initialState, action) => {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}

export { reducer as default, addUserId, addUuid, addWebSocket, createSession, sessionActions }
