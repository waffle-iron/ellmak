module Auth.Model exposing (..)

type alias Authentication =
  { username: String
  , password: String
  , token: String
  , errorMsg: String
  }

new : Authentication
new =
  { username = ""
  , password = ""
  , token = ""
  , errorMsg = ""
  }
