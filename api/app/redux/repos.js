// ----------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------
export const ELLMAK_REPOS_ACTIVATE = 'ellmak/repos/activate'

// ----------------------------------------------------------------------
// Actions
// ----------------------------------------------------------------------
export function activate (repos) {
  return {
    type: ELLMAK_REPOS_ACTIVATE,
    repos: repos
  }
}

// ----------------------------------------------------------------------
// Exported Actions, useful for use with bindActionCreators
// ----------------------------------------------------------------------
export const wssActions = {
  activate
}

// ----------------------------------------------------------------------
// Action Handlers
// ----------------------------------------------------------------------
const ACTION_HANDLERS = {
  [ELLMAK_REPOS_ACTIVATE]: (state, action) => {
    return { ...state, repos: action.repos }
  }
}

// ----------------------------------------------------------------------
// Initial Database State
// ----------------------------------------------------------------------
const initialState = {
  repos: {}
}

// ----------------------------------------------------------------------
// Reducer
// ----------------------------------------------------------------------
export default function reducer (state = initialState, action) {
  const handler = ACTION_HANDLERS[action.type]
  return handler ? handler(state, action) : state
}
