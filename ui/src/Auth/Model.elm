module Auth.Model exposing (..)

import Http exposing (Error(..))
import Jwt exposing (JwtError)


type alias JwtPayload =
    { username : String
    , name : String
    , iat : Int
    , expiry : Float
    }


type alias Authentication =
    { username : String
    , password : String
    , token : String
    , payload : JwtPayload
    , authenticated : Bool
    }


type AuthError
    = HttpError Http.Error
    | TokenError JwtError


defaultAuthentication : Authentication
defaultAuthentication =
    { username = ""
    , password = ""
    , token = ""
    , payload = defaultPayload
    , authenticated = False
    }


defaultPayload : JwtPayload
defaultPayload =
    { username = ""
    , name = ""
    , iat = 0
    , expiry = 0
    }
