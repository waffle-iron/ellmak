// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
const ELLMAK_LOG_SET_LEVEL = 'ellmak/log/set/level'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
const setLevel = (level) => {
  return {
    type: ELLMAK_LOG_SET_LEVEL,
    level: level
  }
}

// ----------------------------------------------------------------------
// Exported Actions, useful for use with bindActionCreators
// ----------------------------------------------------------------------
const logActions = {
  setLevel
}

// ----------------------------------------------------------------------
// Action Handlers
// ----------------------------------------------------------------------
const ACTION_HANDLERS = {
  [ELLMAK_LOG_SET_LEVEL]: (state, action) => {
    return { ...state, level: action.level }
  }
}

// ----------------------------------------------------------------------
// Initial Database State
// ----------------------------------------------------------------------
const initialState = {
  level: 'trace'
}

// ----------------------------------------------------------------------
// Reducer
// ----------------------------------------------------------------------
const reducer = (state = initialState, action) => {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}

export { reducer as default, logActions, ELLMAK_LOG_SET_LEVEL }
