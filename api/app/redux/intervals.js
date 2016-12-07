import _ from 'lodash'

// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
const ELLMAK_INTERVAL_ADD = 'ellmak/interval/add'
const ELLMAK_INTERVAL_REMOVE = 'ellmak/interval/remove'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
const add = (key, value) => {
  return {
    type: ELLMAK_INTERVAL_ADD,
    key: key,
    value: value
  }
}

const remove = (key) => {
  return {
    type: ELLMAK_INTERVAL_REMOVE,
    key: key
  }
}

// ----------------------------------------------------------------------
// Exported Actions, useful for use with bindActionCreators
// ----------------------------------------------------------------------
const intervalsActions = {
  add,
  remove
}

// ----------------------------------------------------------------------
// Action Handlers
// ----------------------------------------------------------------------
const ACTION_HANDLERS = {
  [ELLMAK_INTERVAL_ADD]: (state, action) => {
    return { ...state, intervals: { ...state.intervals, [action.key]: action.value } }
  },
  [ELLMAK_INTERVAL_REMOVE]: (state, action) => {
    return { ...state, intervals: _.omit(state, action.key) }
  }
}

// ----------------------------------------------------------------------
// Initial Database State
// ----------------------------------------------------------------------
const initialState = {
  intervals: {}
}

// ----------------------------------------------------------------------
// Reducer
// ----------------------------------------------------------------------
const reducer = (state = initialState, action) => {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}

export { reducer as default, intervalsActions, ELLMAK_INTERVAL_ADD, ELLMAK_INTERVAL_REMOVE }
