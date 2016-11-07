module Auth.Model exposing (..)

type alias JwtPayload =
    { username : String
    , name : String
    , iat : Int
    , expiry : Int
    }

type alias Authentication =
  { username: String
  , password: String
  , token: String
  , errorMsg: String
  , payload: JwtPayload
  }

new : Authentication
new =
  { username = ""
  , password = ""
  , token = ""
  , errorMsg = ""
  , payload = newPayload
  }

newPayload : JwtPayload
newPayload =
  { username = ""
  , name = ""
  , iat = 0
  , expiry = 0
  }
